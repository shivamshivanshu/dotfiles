return {
	"stevearc/oil.nvim",
	lazy = false,
	keys = {
		{ "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
	},
	opts = {
		watch_for_changes = true,
		view_options = {
			show_hidden = true,
		},
		columns = {
			"icon",
			"permissions",
			"size",
			"mtime",
		},
		keymaps = {
			-- Disable C-h/j/k/l for smart-splits navigation compatibility;
			-- C-x replaces the lost C-h horizontal-split open
			["<C-h>"] = false,
			["<C-j>"] = false,
			["<C-k>"] = false,
			["<C-l>"] = false,
			["<C-x>"] = { "actions.select", opts = { horizontal = true } },
		},
	},
}
