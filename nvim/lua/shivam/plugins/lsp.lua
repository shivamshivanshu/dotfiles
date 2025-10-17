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
			local on_attach = function(client, bufnr)
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end
				local lsp = vim.lsp.buf

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
			local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if ok_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			vim.lsp.config("*", {
				on_attach = on_attach,
				capabilities = capabilities,
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
					},
				},
			})

			vim.lsp.config("cmake", {
			})

			vim.lsp.config("clangd", {
				init_options = {
					clangdFileStatus = true,
					inlayHints = {
						parameterNames = true,
						variableTypes = true,
						functionReturnTypes = true,
					},
				},
			})

			vim.lsp.config("pyright", {
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic",
							autoSearchPaths = true,
						},
					},
				},
			})

			local servers = { "lua_ls", "cmake", "clangd", "pyright" }
			for _, name in ipairs(servers) do
				vim.lsp.enable(name)
			end
		end,
	},
}
