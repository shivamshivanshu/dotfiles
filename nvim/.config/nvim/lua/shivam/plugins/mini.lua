return {
	"echasnovski/mini.nvim",
	event = "VeryLazy",
	config = function()
		require("mini.icons").setup()
		MiniIcons.mock_nvim_web_devicons()

		-- vim-surround style mappings, matching the previous nvim-surround keys
		require("mini.surround").setup({
			mappings = {
				add = "ys",
				delete = "ds",
				replace = "cs",
				find = "",
				find_left = "",
				highlight = "",
				update_n_lines = "",
				suffix_last = "",
				suffix_next = "",
			},
			search_method = "cover_or_next",
		})
		vim.keymap.del("x", "ys")
		vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
		vim.keymap.set("n", "yss", "ys_", { remap = true })

		require("mini.statusline").setup()
		require("mini.tabline").setup()

		require("mini.ai").setup()
		require("mini.move").setup()
		require("mini.bufremove").setup()

		-- mini.tabline shows listed buffers in bufnr order, so left/right
		-- of the current tab is a bufnr comparison
		local function close_buffers(predicate)
			local current = vim.api.nvim_get_current_buf()
			for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
				if info.bufnr ~= current and predicate(info.bufnr, current) then
					MiniBufremove.delete(info.bufnr)
				end
			end
		end
		vim.api.nvim_create_user_command("BufCloseOthers", function()
			close_buffers(function() return true end)
		end, { desc = "Close all listed buffers except the current one" })
		vim.api.nvim_create_user_command("BufCloseLeft", function()
			close_buffers(function(buf, current) return buf < current end)
		end, { desc = "Close buffers left of the current one in the tabline" })
		vim.api.nvim_create_user_command("BufCloseRight", function()
			close_buffers(function(buf, current) return buf > current end)
		end, { desc = "Close buffers right of the current one in the tabline" })

		require("mini.trailspace").setup()
		vim.api.nvim_create_user_command("TrimTrailspace", function()
			MiniTrailspace.trim()
			MiniTrailspace.trim_last_lines()
		end, { desc = "Trim trailing whitespace and trailing blank lines" })

		require("mini.indentscope").setup({ symbol = "│" })
		vim.api.nvim_create_user_command("ToggleIndentScope", function()
			vim.g.miniindentscope_disable = not vim.g.miniindentscope_disable
		end, { desc = "Toggle the indent scope line" })

		local miniclue = require("mini.clue")
		miniclue.setup({
			triggers = {
				{ mode = "n", keys = "<Leader>" },
				{ mode = "x", keys = "<Leader>" },
				{ mode = "n", keys = "g" },
				{ mode = "x", keys = "g" },
				{ mode = "n", keys = "'" },
				{ mode = "n", keys = "`" },
				{ mode = "n", keys = '"' },
				{ mode = "x", keys = '"' },
				{ mode = "i", keys = "<C-r>" },
				{ mode = "c", keys = "<C-r>" },
				{ mode = "n", keys = "<C-w>" },
				{ mode = "n", keys = "z" },
				{ mode = "x", keys = "z" },
				{ mode = "n", keys = "[" },
				{ mode = "n", keys = "]" },
			},
			clues = {
				miniclue.gen_clues.builtin_completion(),
				miniclue.gen_clues.g(),
				miniclue.gen_clues.marks(),
				miniclue.gen_clues.registers(),
				miniclue.gen_clues.windows(),
				miniclue.gen_clues.z(),
			},
		})

		local hipatterns = require("mini.hipatterns")
		hipatterns.setup({
			highlighters = {
				fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
				hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
				todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
				note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
				hex_color = hipatterns.gen_highlighter.hex_color(),
			},
		})
		vim.api.nvim_create_user_command("ToggleHipatterns", function()
			hipatterns.toggle(0)
		end, { desc = "Toggle TODO/FIXME/hex highlighting in this buffer" })
	end,
}
