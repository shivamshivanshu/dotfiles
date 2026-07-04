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
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "VeryLazy",
		config = function()
			require("nvim-treesitter-textobjects").setup({
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			local function sel(obj, desc)
				return function()
					select.select_textobject(obj, "textobjects")
				end, { desc = desc }
			end
			vim.keymap.set({ "x", "o" }, "af", sel("@function.outer", "Outer function"))
			vim.keymap.set({ "x", "o" }, "if", sel("@function.inner", "Inner function"))
			vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer", "Outer class"))
			vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner", "Inner class"))
			vim.keymap.set({ "x", "o" }, "aa", sel("@parameter.outer", "Outer parameter"))
			vim.keymap.set({ "x", "o" }, "ia", sel("@parameter.inner", "Inner parameter"))

			local move = require("nvim-treesitter-textobjects.move")
			local function mv(fn, obj, desc)
				return function()
					fn(obj, "textobjects")
				end, { desc = desc }
			end
			vim.keymap.set({ "n", "x", "o" }, "]m", mv(move.goto_next_start, "@function.outer", "Next function start"))
			vim.keymap.set(
				{ "n", "x", "o" },
				"[m",
				mv(move.goto_previous_start, "@function.outer", "Prev function start")
			)
			vim.keymap.set({ "n", "x", "o" }, "]M", mv(move.goto_next_end, "@function.outer", "Next function end"))
			vim.keymap.set({ "n", "x", "o" }, "[M", mv(move.goto_previous_end, "@function.outer", "Prev function end"))
			vim.keymap.set({ "n", "x", "o" }, "]]", mv(move.goto_next_start, "@class.outer", "Next class start"))
			vim.keymap.set({ "n", "x", "o" }, "[[", mv(move.goto_previous_start, "@class.outer", "Prev class start"))
			vim.keymap.set({ "n", "x", "o" }, "][", mv(move.goto_next_end, "@class.outer", "Next class end"))
			vim.keymap.set({ "n", "x", "o" }, "[]", mv(move.goto_previous_end, "@class.outer", "Prev class end"))
			vim.keymap.set({ "n", "x", "o" }, "]a", mv(move.goto_next_start, "@parameter.inner", "Next parameter"))
			vim.keymap.set({ "n", "x", "o" }, "[a", mv(move.goto_previous_start, "@parameter.inner", "Prev parameter"))

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
