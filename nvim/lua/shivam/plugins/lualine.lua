return {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	event = "VeryLazy", -- Defer loading for faster startup
	opts = {
		options = {
			theme = "gruvbox"
		},
		sections = {
			lualine_c = {
				{
					'filename',
					path = 1, -- 0 = filename, 1 = relative path, 2 = absolute path
				},
			},
		},
	},
}
