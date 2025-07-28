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
		version = "1.32.0",
		opts = {},
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = {},
			},
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls" },
				automatic_enable = false,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")

			local on_attach = function(client, bufnr)
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				local lsp = vim.lsp.buf

				-- LSP-related keymaps (per buffer)
				map("n", "gd", lsp.definition, "Go to Definition")
				map("n", "K", lsp.hover, "Hover Info")
				map("n", "gi", lsp.implementation, "Go to Implementation")
				map("n", "<leader>rn", lsp.rename, "Rename Symbol")
				map("n", "<leader>ca", lsp.code_action, "Code Action")
				map("n", "<leader>f", function() lsp.format({ async = true }) end, "Format Buffer")
				map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
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

				if client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end

			local servers = { "lua_ls", "clangd" }

			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					on_attach = on_attach,
					capabilities = vim.lsp.protocol.make_client_capabilities(),
				})
			end
		end,
	}
}
