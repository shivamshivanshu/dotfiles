return {
	{
		"mason-org/mason.nvim",
		opts = {},
		config = function()
			require("mason").setup()
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		version = "1.32.0",  -- last v1 release
		opts = {},
		dependencies = {
			{
				"mason-org/mason.nvim",
				opts = {},
			},
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")

			local on_attach = function(_, bufnr)
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
			end

			local servers = { "pyright", "lua_ls", "clangd" }

			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					on_attach = on_attach,
					capabilities = vim.lsp.protocol.make_client_capabilities(),
				})
			end
		end,
	}
}
