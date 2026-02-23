return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		opts = {},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = false,
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				"stylua",
				"clang-format",
				"prettier",
			},
			auto_update = false,
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = { "lua_ls", "clangd", "cmake", "pyright", "marksman" },
			automatic_installation = true,
		},
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
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then return end

					local map = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
					end

					map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
					map("n", "K", vim.lsp.buf.hover, "Hover Info")
					map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
					map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
					map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
					map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev Diagnostic")
					map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next Diagnostic")

					if client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if ok_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
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

			vim.lsp.config("marksman", {
				root_markers = { ".marksman.toml", ".git" },
			})

			vim.lsp.enable({ "lua_ls", "clangd", "pyright", "cmake", "marksman" })
		end,
	},
}
