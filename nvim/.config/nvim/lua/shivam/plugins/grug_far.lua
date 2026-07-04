local current_dir = require("shivam.util.paths").current_dir

local function project_root()
	return vim.fs.root(0, ".git") or vim.fn.getcwd()
end

local function open_with(prefills, vertical)
	require("grug-far").open({
		windowCreationCommand = vertical and "vsplit" or "split",
		prefills = prefills,
	})
end

local function visual_selection()
	local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
	return table.concat(lines, "\n")
end

return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },
	keys = {
		{ "<leader>h", function() open_with({}) end, desc = "Search & Replace (horizontal)" },
		{ "<leader>H", function() open_with({}, true) end, desc = "Search & Replace (vertical)" },
		{
			"<leader>hw",
			function() open_with({ search = vim.fn.expand("<cword>") }) end,
			desc = "Replace current word",
		},
		{
			"<leader>hw",
			function() open_with({ search = visual_selection() }) end,
			mode = "v",
			desc = "Replace selection (project-wide)",
		},
		{
			"<leader>hf",
			function() open_with({ paths = vim.fn.expand("%") }) end,
			desc = "Replace in current file",
		},
		{
			"<leader>hd",
			function() open_with({ paths = current_dir() }) end,
			desc = "Replace in current dir",
		},
		{
			"<leader>hp",
			function() open_with({ paths = project_root() }) end,
			desc = "Replace in project root",
		},
	},
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
