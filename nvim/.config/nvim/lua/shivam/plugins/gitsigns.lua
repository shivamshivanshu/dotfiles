local actions = require("shivam.util.actions")

actions.add("git.preview_hunk", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview Git hunk", cmd = "PreviewHunk" })
actions.add("git.reset_hunk", function()
	require("gitsigns").reset_hunk()
end, { desc = "Reset Git hunk", cmd = "ResetHunk" })
actions.add("git.stage_hunk", function()
	require("gitsigns").stage_hunk()
end, { desc = "Stage Git hunk (repeat to unstage)", cmd = "StageHunk" })
actions.add("toggle.git_blame", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle inline Git blame for current line", cmd = "ToggleGitBlame" })
actions.add("git.next_hunk", function()
	if vim.wo.diff then
		vim.cmd.normal({ "]c", bang = true })
	else
		require("gitsigns").nav_hunk("next")
	end
end, { desc = "Next Git hunk / diff change" })
actions.add("git.prev_hunk", function()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	else
		require("gitsigns").nav_hunk("prev")
	end
end, { desc = "Previous Git hunk / diff change" })

actions.map("n", "<leader>gp", "git.preview_hunk")
actions.map("n", "<leader>gu", "git.reset_hunk")
actions.map("n", "<leader>gs", "git.stage_hunk")
actions.map("n", "]c", "git.next_hunk")
actions.map("n", "[c", "git.prev_hunk")

return {
	"lewis6991/gitsigns.nvim",
	event = require("shivam.util.events").BUF_OPEN,
	opts = {},
}
