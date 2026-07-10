return {
	{
		"tadmccorkle/markdown.nvim",
		ft = "markdown",
		opts = {
			mappings = {
				inline_surround_delete = "gsd",
				inline_surround_change = "gsc",
				go_curr_heading = "]h",
			},
		},
	},
	{
		"brianhuster/live-preview.nvim",
		cmd = { "LivePreview" },
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = "markdown",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = { heading = { icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " } } },
	},
}
