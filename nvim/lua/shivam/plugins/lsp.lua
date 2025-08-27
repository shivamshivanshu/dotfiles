return {
	{
		"williamboman/mason.nvim",
		opts = {},
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {},
		dependencies = {
			{ "williamboman/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "clangd", "cmake", "pyright" },
				automatic_installation = true,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local lspconfig = require("lspconfig")

			-- Common on_attach function for all LSPs
			local on_attach = function(client, bufnr)
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				local lsp = vim.lsp.buf

				-- LSP keymaps
				map("n", "gd", lsp.definition, "Go to Definition")
				map("n", "K", lsp.hover, "Hover Info")
				map("n", "gi", lsp.implementation, "Go to Implementation")
				map("n", "<leader>rn", lsp.rename, "Rename Symbol")
				map("n", "<leader>ca", lsp.code_action, "Code Action")
				map("n", "<leader>f", function() lsp.format({ async = true }) end, "Format Buffer")
				map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")

				-- Format visual selection
				map("x", "<leader>f", function()
					local s_start = vim.api.nvim_buf_get_mark(0, "<")
					local s_end   = vim.api.nvim_buf_get_mark(0, ">")
					vim.lsp.buf.format({
						async = true,
						range = {
							start = { s_start[1] - 1, s_start[2] },
							["end"] = { s_end[1] - 1, s_end[2] },
						},
					})
				end, "Format Selection")

				-- Enable virtual text inlay hints if supported
				if client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end

			-- Enhance capabilities for nvim-cmp
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if cmp_ok then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			-- Lua LSP
			lspconfig.lua_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = { diagnostics = { globals = { "vim" } } },
				},
			})

			-- CMake LSP
			lspconfig.cmake.setup({
				on_attach = on_attach,
				capabilities = capabilities,
			})

			-- Clangd (C/C++)
			lspconfig.clangd.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				init_options = {
					clangdFileStatus = true,
					inlayHints = {
						parameterNames = true,
						variableTypes = true,
						functionReturnTypes = true,
					},
				},
			})

			-- Pyright (Python)
			lspconfig.pyright.setup({
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
			})
		end,
	},
}
