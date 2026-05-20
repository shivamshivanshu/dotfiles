return {
	"lewis6991/gitsigns.nvim",
	event = require("shivam.util.events").BUF_OPEN,
	keys = {
		{ "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview Git hunk" },
		{ "<leader>gh", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle Git blame" },
		{ "<leader>gu", function() require("gitsigns").reset_hunk() end, desc = "Reset Git hunk" },
		{ "]c", function() require("gitsigns").next_hunk() end, desc = "Next Git hunk" },
		{ "[c", function() require("gitsigns").prev_hunk() end, desc = "Previous Git hunk" },
	},
	opts = {},
}
