local actions = require("shivam.util.actions")

-- Action bodies require() telescope lazily so registration at spec-import
-- time doesn't force-load the plugin.
local function builtin(picker, opts_fn)
	return function()
		require("telescope.builtin")[picker](opts_fn and opts_fn() or nil)
	end
end

local function dir_opts(kind)
	return function()
		local dir = require("shivam.util.paths").current_dir()
		local short = vim.fn.fnamemodify(dir, ":~")
		return {
			cwd = dir,
			prompt_title = string.format("%s in %s", kind, short),
			results_title = short,
			path_display = { "smart" },
		}
	end
end

local add = actions.add
add("telescope.find_files_dir", builtin("find_files", dir_opts("Files")), {
	desc = "Find files in current (Oil-aware) dir",
	cmd = "SearchFilesDir",
})
add("telescope.live_grep_dir", builtin("live_grep", dir_opts("Grep")), {
	desc = "Live grep in current (Oil-aware) dir",
	cmd = "GrepDir",
})
add("telescope.grep_word_dir", builtin("grep_string", dir_opts("Grep word")), {
	desc = "Grep word under cursor in current (Oil-aware) dir",
	cmd = "GrepWordDir",
})
add("telescope.find_files", builtin("find_files"), { desc = "Find files in cwd", cmd = "SearchFiles" })
add("telescope.live_grep", builtin("live_grep"), { desc = "Live grep in cwd", cmd = "Grep" })
add("telescope.grep_word", builtin("grep_string"), { desc = "Grep word under cursor in cwd", cmd = "GrepWord" })
add("telescope.help", builtin("help_tags"), { desc = "Search help tags", cmd = "SearchHelp" })
add("telescope.keymaps", builtin("keymaps"), { desc = "Search keymaps", cmd = "SearchKeymaps" })
add("telescope.diagnostics", builtin("diagnostics"), { desc = "Search diagnostics", cmd = "SearchDiagnostics" })
add("telescope.resume", builtin("resume"), { desc = "Resume last picker", cmd = "SearchResume" })
add("telescope.picker_history", builtin("pickers"), { desc = "Search picker history", cmd = "SearchPickers" })
add(
	"telescope.recent_files",
	builtin("oldfiles", function()
		return { cwd_only = true }
	end),
	{ desc = "Search recent files in cwd", cmd = "SearchRecent" }
)
add("telescope.buffers", builtin("buffers"), { desc = "Find existing buffers", cmd = "SearchBuffers" })
add("telescope.doc_symbols", builtin("lsp_document_symbols"), {
	desc = "LSP symbols in current buffer",
	cmd = "SearchSymbols",
})
add(
	"telescope.buffer_fuzzy",
	builtin("current_buffer_fuzzy_find", function()
		return require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
	end),
	{ desc = "Fuzzy search in current buffer", cmd = "BufFuzzyFind" }
)
add(
	"telescope.grep_open_files",
	builtin("live_grep", function()
		return { grep_open_files = true, prompt_title = "Live Grep in Open Files" }
	end),
	{ desc = "Live grep in open files", cmd = "GrepOpenFiles" }
)
add(
	"telescope.nvim_config_files",
	builtin("find_files", function()
		return { cwd = vim.fn.stdpath("config") }
	end),
	{ desc = "Find files in nvim config", cmd = "SearchNvimConfig" }
)
add("actions.picker", actions.picker, {
	desc = "Fuzzy-find and run any registered action",
	cmd = "Actions",
})

local bind = actions.map
bind("n", "<leader>so", "telescope.find_files_dir", { desc = "[S]earch Files in current dir" })
bind("n", "<leader>st", "telescope.live_grep_dir", { desc = "[S]earch by Grep in current dir" })
bind("n", "<leader>sW", "telescope.grep_word_dir", { desc = "[S]earch [W]ord in current dir" })
bind("n", "<leader>sh", "telescope.help", { desc = "[S]earch [H]elp" })
bind("n", "<leader>sk", "telescope.keymaps", { desc = "[S]earch [K]eymaps" })
bind("n", "<leader>sf", "telescope.find_files", { desc = "[S]earch [F]iles" })
bind("n", "<leader>sw", "telescope.grep_word", { desc = "[S]earch current [W]ord" })
bind("n", "<leader>sg", "telescope.live_grep", { desc = "[S]earch by [G]rep" })
bind("n", "<leader>sd", "telescope.diagnostics", { desc = "[S]earch [D]iagnostics" })
bind("n", "<leader>sr", "telescope.resume", { desc = "[S]earch [R]esume" })
bind("n", "<leader>sR", "telescope.picker_history", { desc = "[S]earch picker history" })
bind("n", "<leader>s.", "telescope.recent_files", { desc = '[S]earch Recent Files ("." for repeat)' })
bind("n", "<leader><leader>", "telescope.buffers", { desc = "[ ] Find existing buffers" })
bind("n", "<leader>ss", "telescope.doc_symbols", { desc = "[S]earch [S]ymbols in current buffer" })
bind("n", "<leader>/", "telescope.buffer_fuzzy", { desc = "[/] Fuzzily search in current buffer" })
bind("n", "<leader>s/", "telescope.grep_open_files", { desc = "[S]earch [/] in Open Files" })
bind("n", "<leader>sn", "telescope.nvim_config_files", { desc = "[S]earch [N]eovim files" })
bind("n", "<leader>sa", "actions.picker", { desc = "[S]earch [A]ctions" })

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
	end,
}
