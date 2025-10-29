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
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				-- Formatters
				"stylua",        -- Lua formatter
				"black",         -- Python formatter
				"isort",         -- Python import sorter
				"clang-format",  -- C/C++ formatter
				"prettier",      -- JS/TS/JSON/YAML/HTML/CSS formatter
			},
			auto_update = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			-- Define on_attach function
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
				map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")

				-- Format using conform.nvim (fallback to LSP if conform not available)
				map("n", "<leader>f", function()
					local ok, conform = pcall(require, "conform")
					if ok then
						conform.format({ async = true, lsp_fallback = true })
					else
						vim.lsp.buf.format({ async = true })
					end
				end, "Format Buffer")

				-- Format visual selection using conform
				map("x", "<leader>f", function()
					local ok, conform = pcall(require, "conform")
					if ok then
						conform.format({ async = true, lsp_fallback = true })
					else
						vim.lsp.buf.format({ async = true })
					end
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

			-- Get lspconfig
			local lspconfig = require("lspconfig")

			-- Server-specific settings
			local server_settings = {
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							workspace = { checkThirdParty = false },
						},
					},
				},
				clangd = {
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
					},
					init_options = {
						clangdFileStatus = true,
						usePlaceholders = true,
						completeUnimported = true,
						semanticHighlighting = true,
					},
				},
				pyright = {
					settings = {
						python = {
							analysis = {
								typeCheckingMode = "basic",
								autoSearchPaths = true,
							},
						},
					},
				},
				cmake = {},
			}

			-- Setup mason-lspconfig with handlers
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "clangd", "cmake", "pyright" },
				automatic_installation = true,
				handlers = {
					-- Default handler for all servers
					function(server_name)
						local config = server_settings[server_name] or {}
						config.on_attach = on_attach
						config.capabilities = capabilities
						lspconfig[server_name].setup(config)
					end,
				},
			})
		end,
	},
}
