return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
	opts = function()
		local dv = require("diffview.actions")

		local panel = {
			["<leader>e"] = false,
			["<leader>b"] = false,
			["<localleader>e"] = dv.focus_files,
			["<localleader>b"] = dv.toggle_files,
		}

		local conflict_hunk = {
			["<leader>co"] = false,
			["<leader>ct"] = false,
			["<leader>cb"] = false,
			["<leader>ca"] = false,
			["<localleader>co"] = dv.conflict_choose("ours"),
			["<localleader>ct"] = dv.conflict_choose("theirs"),
			["<localleader>cb"] = dv.conflict_choose("base"),
			["<localleader>ca"] = dv.conflict_choose("all"),
		}

		local conflict_file = {
			["<leader>cO"] = false,
			["<leader>cT"] = false,
			["<leader>cB"] = false,
			["<leader>cA"] = false,
			["<localleader>cO"] = dv.conflict_choose_all("ours"),
			["<localleader>cT"] = dv.conflict_choose_all("theirs"),
			["<localleader>cB"] = dv.conflict_choose_all("base"),
			["<localleader>cA"] = dv.conflict_choose_all("all"),
		}

		return {
			keymaps = {
				view = vim.tbl_extend("error", {}, panel, conflict_hunk, conflict_file),
				file_panel = vim.tbl_extend("error", {}, panel, conflict_file),
				file_history_panel = panel,
			},
		}
	end,
}
