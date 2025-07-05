return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup()
		local map = vim.keymap.set
		map("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Show Git diff on current line" })
		map("n", "<leader>gh", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Show Git history on current line" })
	end
}
