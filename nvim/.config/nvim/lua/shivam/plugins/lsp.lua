return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = { "mason.nvim" },
		opts = {
			ensure_installed = {
				"stylua",
				"clang-format",
				"prettier",
				"ruff",
				"cmakelang", -- provides cmake-format (conform's cmake_format)
			},
			auto_update = false,
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason.nvim" },
		opts = {
			ensure_installed = { "lua_ls", "clangd", "cmake", "pyright", "markdown_oxide", "ltex_plus" },
			automatic_enable = false,
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = require("shivam.util.events").BUF_OPEN,
		dependencies = {
			"saghen/blink.cmp",
			"mason.nvim",
			"mason-lspconfig.nvim",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("shivam-lsp-attach", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then
						return
					end

					local map = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
					end

					map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
					map("n", "K", vim.lsp.buf.hover, "Hover Info")
					map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
					map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
					map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
					map("n", "[d", function()
						vim.diagnostic.jump({ count = -1 })
					end, "Prev Diagnostic")
					map("n", "]d", function()
						vim.diagnostic.jump({ count = 1 })
					end, "Next Diagnostic")

					if client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok_blink, blink = pcall(require, "blink.cmp")
			if ok_blink then
				capabilities = blink.get_lsp_capabilities(capabilities)
			end

			vim.lsp.config("*", { capabilities = capabilities })

			vim.lsp.config("lua_ls", {
				root_markers = { ".luarc.json", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
					},
				},
			})

			vim.lsp.config("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
				},
				root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", ".git" },
			})

			vim.lsp.config("pyright", {
				root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py", "requirements.txt", ".git" },
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic",
							autoSearchPaths = true,
						},
					},
				},
			})

			vim.lsp.config("cmake", {
				root_markers = { "CMakePresets.json", "CTestConfig.cmake", ".git", "build", "cmake" },
			})

			vim.lsp.config("markdown_oxide", {
				root_markers = { ".obsidian", ".moxide.toml", ".git" },
			})

			-- spelling/grammar via LanguageTool; narrowed from the upstream
			-- filetype list so the Java server only attaches to prose buffers
			vim.lsp.config("ltex_plus", {
				filetypes = { "markdown", "gitcommit", "text", "tex", "plaintex", "typst" },
				-- blank JAVA_HOME so the launcher falls back to its bundled JDK 21
				cmd_env = { JAVA_HOME = "" },
				settings = {
					ltex = {
						language = "en-US",
						checkFrequency = "save",
						additionalRules = { enablePickyRules = true },
					},
				},
			})

			-- not in nvim-lspconfig/mason; installed via `cargo install iwe iwes`
			vim.lsp.config("iwe", {
				cmd = { "iwes" },
				filetypes = { "markdown" },
				-- attach only inside `iwe init`ed vaults; skipping on_dir (unlike
				-- unmatched root_markers) also prevents single-file-mode attach
				root_dir = function(bufnr, on_dir)
					local vault = vim.fs.root(vim.api.nvim_buf_get_name(bufnr), ".iwe")
					if vault then
						on_dir(vault)
					end
				end,
			})

			vim.lsp.enable({ "lua_ls", "clangd", "pyright", "cmake", "markdown_oxide", "ltex_plus", "iwe" })

			vim.api.nvim_create_user_command("ToggleDiagnosticVirtualText", function()
				local current = vim.diagnostic.config().virtual_text
				local enabled = current ~= false and current ~= nil
				vim.diagnostic.config({ virtual_text = not enabled })
				vim.notify("Diagnostic virtual_text: " .. tostring(not enabled))
			end, { desc = "Toggle LSP diagnostic virtual text" })
		end,
	},
}
