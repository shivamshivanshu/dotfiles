return {
	"saghen/blink.cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		"saghen/blink.lib",
		"L3MON4D3/LuaSnip",
		"rafamadriz/friendly-snippets",
	},
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = {
			preset = "default",
			["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			["<CR>"] = { "accept", "fallback" },
			["<C-n>"] = { "select_next", "snippet_forward", "fallback" },
			["<C-p>"] = { "select_prev", "snippet_backward", "fallback" },
		},
		snippets = { preset = "luasnip" },
		sources = {
			default = { "lsp", "snippets", "buffer", "path" },
		},
		cmdline = {
			enabled = true,
			keymap = { preset = "cmdline" },
		},
		fuzzy = {
			implementation = "prefer_rust",
		},
	},
	config = function(_, opts)
		require("luasnip.loaders.from_vscode").lazy_load()
		require("blink.cmp").setup(opts)
	end,
}
