return {
	"ellisonleao/gruvbox.nvim",
	lazy = false, -- Must load immediately for colorscheme
	priority = 1000,
	config = function()
		require("gruvbox").setup({
			contrast = "hard",      -- or "soft", "medium"
			italic = {
				strings = true,
				comments = true,
				operators = false,
				folds = true,
			},
			transparent_mode = false,
		})
		vim.cmd.colorscheme("gruvbox")
	end,
}

