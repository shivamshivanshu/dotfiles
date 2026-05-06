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
		{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Tmux nav left" },
		{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Tmux nav down" },
		{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Tmux nav up" },
		{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Tmux nav right" },
		{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Tmux nav previous" },
	},
}
