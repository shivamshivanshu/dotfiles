return {
	{
		"williamboman/mason.nvim",
		lazy = false, -- Load immediately for LSP setup
		opts = {},
		config = function()
			require("mason").setup()
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = false,
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				"stylua", -- Lua formatter
				"clang-format", -- C/C++ formatter
				"prettier", -- JS/TS/JSON/YAML/HTML/CSS formatter
			},
			auto_update = true,
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local on_attach = function(client, bufnr)
				vim.notify(string.format("LSP attached: %s", client.name), vim.log.levels.INFO)

				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end
				local lsp = vim.lsp.buf

				map("n", "gd", lsp.definition, "Go to Definition")
				map("n", "K", lsp.hover, "Hover Info")
				map("n", "gi", lsp.implementation, "Go to Implementation")
				map("n", "<leader>rn", lsp.rename, "Rename Symbol")
				map("n", "<leader>ca", lsp.code_action, "Code Action")
				map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")

				if client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if ok_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "clangd", "cmake", "pyright" },
				automatic_installation = true,
			})

			vim.lsp.config.lua_ls = {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				root_markers = { ".luarc.json", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
					},
				},
			}

			vim.lsp.config.clangd = {
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
				},
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
				root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", ".git" },
				on_attach = on_attach,
				capabilities = capabilities,
			}

			vim.lsp.config.pyright = {
				cmd = { "pyright-langserver", "--stdio" },
				filetypes = { "python" },
				root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py", "requirements.txt", ".git" },
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic",
							autoSearchPaths = true,
						},
					},
				},
			}

			vim.lsp.config.cmake = {
				cmd = { "cmake-language-server" },
				filetypes = { "cmake" },
				root_markers = { "CMakePresets.json", "CTestConfig.cmake", ".git", "build", "cmake" },
				on_attach = on_attach,
				capabilities = capabilities,
			}

			vim.lsp.enable({ "lua_ls", "clangd", "pyright", "cmake" })
		end,
	},
}
