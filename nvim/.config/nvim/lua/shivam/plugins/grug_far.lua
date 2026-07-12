return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },
	init = function()
		vim.api.nvim_create_user_command("GrugFarWord", function()
			require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
		end, { desc = "Search/replace the word under cursor project-wide" })

		vim.api.nvim_create_user_command("GrugFarAst", function()
			-- flags override: the setup-level rg flags are invalid for ast-grep
			require("grug-far").open({ engine = "astgrep", prefills = { flags = "" } })
		end, { desc = "Structural search/replace via ast-grep patterns" })
	end,
	opts = {
		engine = "ripgrep",
		transient = true,
		windowCreationCommand = "split",
		prefills = { flags = "--ignore-case --hidden" },
		history = { maxHistoryLines = 1000 },
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
