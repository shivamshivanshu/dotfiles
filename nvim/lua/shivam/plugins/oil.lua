return {
	'stevearc/oil.nvim',
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("oil").setup({
			view_options = {
				show_hidden = true,
			},
			columns = {
				"permissions",
				"size",
				"mtime",
			}
		})
		local map = vim.keymap.set

		map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent Dir" })
	end,
}
