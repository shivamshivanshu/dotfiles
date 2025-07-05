return {
	'akinsho/bufferline.nvim', 
	version = "*", 
	dependencies = 'nvim-tree/nvim-web-devicons',
	config = function()
		require("bufferline").setup()
		local map = vim.keymap.set
		map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
		map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
	end
}
