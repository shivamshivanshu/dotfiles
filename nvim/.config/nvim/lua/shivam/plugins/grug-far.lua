return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },
	keys = {
		{
			"<leader>h",
			function()
				require("grug-far").open({ windowCreationCommand = "split" })
			end,
			desc = "Search & Replace (horizontal)",
		},
		{
			"<leader>H",
			function()
				require("grug-far").open({ windowCreationCommand = "vsplit" })
			end,
			desc = "Search & Replace (vertical)",
		},
		{
			"<leader>hw",
			function()
				require("grug-far").open({
					windowCreationCommand = "split",
					prefills = { search = vim.fn.expand("<cword>") },
				})
			end,
			desc = "Replace current word",
		},
		{ "<leader>hw", "<cmd>GrugFarWithin<cr>", mode = "v", desc = "Replace selection" },
		{
			"<leader>hf",
			function()
				require("grug-far").open({
					windowCreationCommand = "split",
					prefills = { paths = vim.fn.expand("%") },
				})
			end,
			desc = "Replace in current file",
		},
	},
	opts = {
		engine = "ripgrep",
		transient = true,
		windowCreationCommand = "split",
		keymaps = {
			replace = { n = "<leader>ha" },
			qflist = { n = "<leader>hq" },
			syncLocations = { n = "<leader>hs" },
			syncLine = { n = "<leader>hl" },
			close = { n = "q" },
			historyOpen = { n = "<leader>ht" },
			refresh = { n = "<leader>hr" },
			gotoLocation = { n = "<cr>" },
			pickHistoryEntry = { n = "<cr>" },
		},
	},
}
