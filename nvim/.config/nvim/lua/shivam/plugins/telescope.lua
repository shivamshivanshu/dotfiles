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

		-- Enable Telescope extensions if they are installed
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		-- See `:help telescope.builtin`
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

		local function dir_find_files()
			local dir = current_dir()
			require("telescope.builtin").find_files(titled_opts("Files", dir))
		end

		local function dir_live_grep()
			local dir = current_dir()
			require("telescope.builtin").live_grep(titled_opts("Grep", dir))
		end

		local function dir_grep_string()
			local dir = current_dir()
			require("telescope.builtin").grep_string(titled_opts("Grep word", dir))
		end

		map("n", "<leader>so", dir_find_files, { desc = "[S]earch Files in current dir" })
		map("n", "<leader>st", dir_live_grep, { desc = "[S]earch by Grep in current dir" })
		map("n", "<leader>sW", dir_grep_string, { desc = "[S]earch [W]ord in current dir" })

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

		-- Slightly advanced example of overriding default behavior and theme
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

		-- Shortcut for searching your Neovim configuration files
		vim.keymap.set("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[S]earch [N]eovim files" })
	end,
}
