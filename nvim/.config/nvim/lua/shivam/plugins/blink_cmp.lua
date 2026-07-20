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
	-- lazy.nvim's build hook doesn't reliably rerun after a plugin update bumps the
	-- commit, leaving the native lib stale; self-heal here instead of relying on it.
	config = function(_, opts)
		local blink = require("blink.cmp")
		if not blink.library_available() then
			blink.build():pwait()
		end
		blink.setup(opts)
	end,
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
