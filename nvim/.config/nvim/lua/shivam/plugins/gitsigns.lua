return {
	"lewis6991/gitsigns.nvim",
	event = require("shivam.util.events").BUF_OPEN,
	keys = {
		{
			"<leader>gp",
			function()
				require("gitsigns").preview_hunk()
			end,
			desc = "Preview Git hunk",
		},
		{
			"<leader>gu",
			function()
				require("gitsigns").reset_hunk()
			end,
			desc = "Reset Git hunk",
		},
		{
			"]c",
			function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					require("gitsigns").nav_hunk("next")
				end
			end,
			desc = "Next Git hunk / diff change",
		},
		{
			"[c",
			function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					require("gitsigns").nav_hunk("prev")
				end
			end,
			desc = "Previous Git hunk / diff change",
		},
	},
	opts = {},
}
