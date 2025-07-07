return {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	config = function()
		require("lualine").setup({
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
		})
	end
}
