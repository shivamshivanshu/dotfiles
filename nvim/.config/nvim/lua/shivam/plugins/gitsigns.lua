local actions = require("shivam.util.actions")

local add = actions.add
add("git.preview_hunk", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview Git hunk", cmd = "PreviewHunk" })
add("git.reset_hunk", function()
	require("gitsigns").reset_hunk()
end, { desc = "Reset Git hunk", cmd = "ResetHunk" })
add("git.next_hunk", function()
	if vim.wo.diff then
		vim.cmd.normal({ "]c", bang = true })
	else
		require("gitsigns").nav_hunk("next")
	end
end, { desc = "Next Git hunk / diff change" })
add("git.prev_hunk", function()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	else
		require("gitsigns").nav_hunk("prev")
	end
end, { desc = "Previous Git hunk / diff change" })

local map = actions.map
map("n", "<leader>gp", "git.preview_hunk")
map("n", "<leader>gu", "git.reset_hunk")
map("n", "]c", "git.next_hunk")
map("n", "[c", "git.prev_hunk")

return {
	"lewis6991/gitsigns.nvim",
	event = require("shivam.util.events").BUF_OPEN,
	opts = {},
}
