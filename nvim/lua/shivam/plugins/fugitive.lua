return {
	"tpope/vim-fugitive",
	event = "VeryLazy",
	config = function()
		local map = vim.keymap.set
		map("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
		map("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
		map("n", "<leader>gP", "<cmd>Git push<CR>", { desc = "Git push" })
		map("n", "<leader>gl", "<cmd>Git pull --rebase<CR>", { desc = "Git pull --rebase" })
		map("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
	end,
}
