local blame_on = false -- mirrors current_line_blame; opts default it to off

return {
	"lewis6991/gitsigns.nvim",
	event = require("shivam.util.events").BUF_OPEN,
	keys = {
		{ "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview Git hunk" },
		{
			"<leader>gy",
			function()
				local file = vim.fn.expand("%:p")
				local line = vim.fn.line(".")
				local blame = vim.fn.systemlist({ "git", "blame", "-L", line .. "," .. line, "--porcelain", file })
				if vim.v.shell_error ~= 0 or #blame == 0 then
					vim.notify("git blame failed", vim.log.levels.WARN)
					return
				end
				local hash = blame[1]:match("^(%S+)")
				if not hash or hash:match("^0+$") then
					vim.notify("Line not committed yet", vim.log.levels.WARN)
					return
				end
				vim.fn.setreg("+", hash)
				vim.notify("Copied commit hash: " .. hash)
			end,
			desc = "Copy commit hash for current line",
		},
		{
			"<leader>gh",
			function()
				require("gitsigns").toggle_current_line_blame()
				blame_on = not blame_on
				vim.notify("Git blame: " .. (blame_on and "enabled" or "disabled"))
			end,
			desc = "Toggle Git blame",
		},
		{ "<leader>gu", function() require("gitsigns").reset_hunk() end, desc = "Reset Git hunk" },
		{ "]c", function() require("gitsigns").nav_hunk("next") end, desc = "Next Git hunk" },
		{ "[c", function() require("gitsigns").nav_hunk("prev") end, desc = "Previous Git hunk" },
	},
	opts = {},
}
