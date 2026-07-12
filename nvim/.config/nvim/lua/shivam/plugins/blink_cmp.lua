return {
	"saghen/blink.cmp",
	build = function()
		require("blink.cmp").build():pwait()
	end,
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		"saghen/blink.lib",
		"rafamadriz/friendly-snippets",
	},
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = {
			preset = "default",
			["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			["<CR>"] = { "select_and_accept", "fallback" },
			["<C-n>"] = { "select_next", "snippet_forward", "fallback" },
			["<C-p>"] = { "select_prev", "snippet_backward", "fallback" },
		},
		sources = {
			default = { "lsp", "snippets", "buffer", "path" },
		},
		cmdline = {
			enabled = true,
			keymap = {
				preset = "cmdline",
				["<C-y>"] = { "select_and_accept", "fallback" },
			},
			completion = {
				menu = { auto_show = true },
			},
		},
		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},
	},
}
