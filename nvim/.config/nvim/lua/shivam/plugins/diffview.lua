return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
	keys = {
		{ "<leader>dv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open (working tree)" },
		{ "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
		{ "<leader>df", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
	},
}
