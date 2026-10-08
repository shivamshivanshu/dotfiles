local actions = require("shivam.util.actions")

actions.add("grug.open", function()
	require("grug-far").open()
end, { desc = "Search/replace project-wide" })
actions.map("n", "<leader>hh", "grug.open")

actions.add("grug.word", function()
	require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Search/replace the word under cursor project-wide", cmd = "GrugFarWord" })

actions.add("grug.ast", function()
	-- flags override: the setup-level rg flags are invalid for ast-grep
	require("grug-far").open({ engine = "astgrep", prefills = { flags = "" } })
end, { desc = "Structural search/replace via ast-grep patterns", cmd = "GrugFarAst" })

return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },
	opts = {
		engine = "ripgrep",
		transient = true,
		windowCreationCommand = "split",
		prefills = { flags = "--ignore-case --hidden" },
		history = { maxHistoryLines = 1000 },
		keymaps = {
			close = { n = "q" },
			gotoLocation = { n = "<cr>" },
			pickHistoryEntry = { n = "<cr>" },
		},
	},
}
