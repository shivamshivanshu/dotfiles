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

		require("mini.indentscope").setup({ symbol = "│" })

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
	end,
}
