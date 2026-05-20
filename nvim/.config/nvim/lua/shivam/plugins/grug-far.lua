return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },
	keys = {
		{ "<leader>h", "<cmd>GrugFar<cr>", desc = "Search & Replace (grug-far)" },
		{
			"<leader>hw",
			function()
				require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
			end,
			desc = "Replace current word",
		},
		{ "<leader>hw", "<cmd>GrugFarWithin<cr>", mode = "v", desc = "Replace selection" },
		{
			"<leader>hf",
			function()
				require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
			end,
			desc = "Replace in current file",
		},
	},
	opts = {
		engine = "ripgrep",
		transient = true,
		windowCreationCommand = "vsplit",
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
