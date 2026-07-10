return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
	},
	config = function()
		local function refresh_picker(prompt_bufnr)
			local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
			picker:refresh(picker.finder, { reset_prompt = false })
		end

		require("telescope").setup({
			defaults = {
				mappings = {
					i = { ["<C-r>"] = refresh_picker },
					n = { ["<C-r>"] = refresh_picker },
				},
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
		})

		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		local builtin = require("telescope.builtin")
		local map = vim.keymap.set

		local current_dir = require("shivam.util.paths").current_dir

		local function titled_opts(kind, dir)
			local short = vim.fn.fnamemodify(dir, ":~")
			return {
				cwd = dir,
				prompt_title = string.format("%s in %s", kind, short),
				results_title = short,
				path_display = { "smart" },
			}
		end

		local function dir_picker(picker, kind)
			return function()
				picker(titled_opts(kind, current_dir()))
			end
		end

		map("n", "<leader>so", dir_picker(builtin.find_files, "Files"), { desc = "[S]earch Files in current dir" })
		map("n", "<leader>st", dir_picker(builtin.live_grep, "Grep"), { desc = "[S]earch by Grep in current dir" })
		map("n", "<leader>sW", dir_picker(builtin.grep_string, "Grep word"), { desc = "[S]earch [W]ord in current dir" })

		map("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
		map("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
		map("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
		map("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
		map("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
		map("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		map("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
		map("n", "<leader>sR", builtin.pickers, { desc = "[S]earch picker history" })
		map("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
		map("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
		map("n", "<leader>ss", builtin.lsp_document_symbols, { desc = "[L]SP [S]ymbols in current buffer" })

		map("n", "<leader>/", function()
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end, { desc = "[/] Fuzzily search in current buffer" })

		map("n", "<leader>s/", function()
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end, { desc = "[S]earch [/] in Open Files" })

		vim.keymap.set("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[S]earch [N]eovim files" })
	end,
}
