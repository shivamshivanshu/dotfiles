return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" }, -- Load when opening a file
	config = function()
		local gitsigns = require("gitsigns")
		gitsigns.setup()

		local map = vim.keymap.set
		map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview Git hunk" })
		map("n", "<leader>gh", gitsigns.toggle_current_line_blame, { desc = "Toggle Git blame" })
		map("n", "<leader>gu", gitsigns.reset_hunk, { desc = "Reset Git hunk" })
		map("n", "]c", gitsigns.next_hunk, { desc = "Next Git hunk" })
		map("n", "[c", gitsigns.prev_hunk, { desc = "Previous Git hunk" })
	end
}
