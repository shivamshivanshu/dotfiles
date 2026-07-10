local parsers = {
	"lua",
	"python",
	"bash",
	"c",
	"cpp",
	"json",
	"markdown",
	"markdown_inline",
	"yaml",
	"vim",
	"vimdoc",
	"starlark",
	"java",
	"make",
	"cmake",
	"html",
	"css",
	"javascript",
	"typescript",
	"tmux",
	"rust",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = function()
			require("nvim-treesitter").update()
		end,
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("shivam-treesitter-start", { clear = true }),
				callback = function(ev)
					pcall(vim.treesitter.start, ev.buf)
				end,
			})
		end,
		config = function()
			if vim.fn.executable("tree-sitter") == 0 then
				vim.schedule(function()
					vim.notify(
						"tree-sitter CLI not found; parsers not installed.\nInstall via: cargo install tree-sitter-cli (or 'brew install tree-sitter' on macOS)",
						vim.log.levels.WARN
					)
				end)
				return
			end

			local installed = require("nvim-treesitter.config").get_installed()
			local to_install = vim.iter(parsers)
				:filter(function(p)
					return not vim.tbl_contains(installed, p)
				end)
				:totable()
			if #to_install > 0 then
				vim.schedule(function()
					require("nvim-treesitter").install(to_install)
				end)
			end
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = require("shivam.util.events").BUF_OPEN,
		config = function()
			require("treesitter-context").setup({ max_lines = 4 })
			vim.api.nvim_create_user_command("GoToContext", function(a)
				require("treesitter-context").go_to_context(tonumber(a.args) or 1)
			end, { nargs = "?", desc = "Jump to the enclosing context line (arg = levels up)" })
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "VeryLazy",
		config = function()
			require("nvim-treesitter-textobjects").setup({
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			local function sel(lhs, obj, desc)
				vim.keymap.set({ "x", "o" }, lhs, function()
					select.select_textobject(obj, "textobjects")
				end, { desc = desc })
			end
			sel("af", "@function.outer", "Outer function")
			sel("if", "@function.inner", "Inner function")
			sel("ac", "@class.outer", "Outer class")
			sel("ic", "@class.inner", "Inner class")
			sel("aa", "@parameter.outer", "Outer parameter")
			sel("ia", "@parameter.inner", "Inner parameter")

			local move = require("nvim-treesitter-textobjects.move")
			local function mv(lhs, fn, obj, desc)
				vim.keymap.set({ "n", "x", "o" }, lhs, function()
					fn(obj, "textobjects")
				end, { desc = desc })
			end
			mv("]m", move.goto_next_start, "@function.outer", "Next function start")
			mv("[m", move.goto_previous_start, "@function.outer", "Prev function start")
			mv("]M", move.goto_next_end, "@function.outer", "Next function end")
			mv("[M", move.goto_previous_end, "@function.outer", "Prev function end")
			mv("]]", move.goto_next_start, "@class.outer", "Next class start")
			mv("[[", move.goto_previous_start, "@class.outer", "Prev class start")
			mv("][", move.goto_next_end, "@class.outer", "Next class end")
			mv("[]", move.goto_previous_end, "@class.outer", "Prev class end")
			mv("]a", move.goto_next_start, "@parameter.inner", "Next parameter")
			mv("[a", move.goto_previous_start, "@parameter.inner", "Prev parameter")

			local swap = require("nvim-treesitter-textobjects.swap")
			vim.keymap.set("n", "<leader>a", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "Swap with next parameter" })
			vim.keymap.set("n", "<leader>A", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "Swap with previous parameter" })
		end,
	},
}
