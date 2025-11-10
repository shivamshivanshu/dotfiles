return {
	"hrsh7th/nvim-cmp",
	event = { "InsertEnter", "CmdlineEnter" }, -- Load only when entering insert mode or cmd mode
	dependencies = {
		"hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
		"hrsh7th/cmp-buffer", -- buffer completions
		"hrsh7th/cmp-path",   -- filesystem paths
		"saadparwaiz1/cmp_luasnip", -- snippet completions
		"L3MON4D3/LuaSnip",   -- snippet engine
		"rafamadriz/friendly-snippets",
		"hrsh7th/cmp-cmdline",
	},
	config = function()
		local cmp     = require("cmp")
		local luasnip = require("luasnip")

		-- Load VSCode-style snippets
		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-Space>"] = cmp.mapping.complete(),
				["<CR>"]      = cmp.mapping.confirm({ select = true }),
				["<C-n>"]     = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<C-p>"]     = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
			}, {
				{ name = "buffer" },
				{ name = "path" },
			}),
		})

		-- Optional: enable completion in the command line
		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = { { name = "buffer" } },
		})
		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})
	end
}
