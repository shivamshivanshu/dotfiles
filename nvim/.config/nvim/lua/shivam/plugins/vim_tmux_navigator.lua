return {
	"christoomey/vim-tmux-navigator",
	cmd = {
		"TmuxNavigateLeft",
		"TmuxNavigateDown",
		"TmuxNavigateUp",
		"TmuxNavigateRight",
		"TmuxNavigatePrevious",
		"TmuxNavigatorProcessList",
	},
	keys = {
		{ "<c-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Tmux nav left" },
		{ "<c-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Tmux nav down" },
		{ "<c-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Tmux nav up" },
		{ "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Tmux nav right" },
		{ "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Tmux nav previous" },
	},
}
