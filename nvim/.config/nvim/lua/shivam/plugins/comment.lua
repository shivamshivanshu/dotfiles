return {
	'numToStr/Comment.nvim',
	event = { "BufReadPost", "BufNewFile" },
	keys = {
		{ "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
		{ "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
	},
	opts = {},
}
