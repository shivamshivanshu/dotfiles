return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
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
			-- Disable C-h/j/k/l for vim-tmux-navigator compatibility
			["<C-h>"] = false,
			["<C-j>"] = false,
			["<C-k>"] = false,
			["<C-l>"] = false,
		},
	},
}
