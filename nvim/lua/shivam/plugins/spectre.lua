return {
	"nvim-pack/nvim-spectre",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "<leader>h", '<cmd>lua require("spectre").toggle()<CR>', desc = "Open Spectre (Search & Replace)" },
		{ "<leader>hw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', desc = "Replace current word" },
		{ "<leader>hw", '<esc><cmd>lua require("spectre").open_visual()<CR>', mode = "v", desc = "Replace selection" },
		{ "<leader>hf", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', desc = "Replace in current file" },
	},
	opts = {
		color_devicons = true,
		open_cmd = "new",
		live_update = false,
		mapping = {
			["toggle_line"] = {
				map = "dd",
				cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
				desc = "toggle item",
			},
			["enter_file"] = {
				map = "<cr>",
				cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
				desc = "open file",
			},
			["show_option_menu"] = {
				map = "?",
				cmd = "<cmd>lua require('spectre').show_options()<CR>",
				desc = "show options",
			},
			["run_current_replace"] = {
				map = "<leader>hc",
				cmd = "<cmd>lua require('spectre').replace_current_line()<CR>",
				desc = "replace current",
			},
			["run_replace"] = {
				map = "<leader>ha",
				cmd = "<cmd>lua require('spectre').replace()<CR>",
				desc = "replace all",
			},
		},
		find_engine = {
			["rg"] = {
				cmd = "rg",
				args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
				options = {
					["hidden"] = { value = "--hidden", icon = "[H]", desc = "search hidden files" },
					["word"] = { value = "--word-regexp", icon = "[W]", desc = "match whole word" },
				},
			},
		},
		default = {
			find = { cmd = "rg" },
			replace = { cmd = "sed" },
		},
	},
}
