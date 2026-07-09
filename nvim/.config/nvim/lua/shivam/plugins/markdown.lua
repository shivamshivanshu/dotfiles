return {
	{
		"tadmccorkle/markdown.nvim",
		ft = "markdown",
		opts = {
			mappings = {
				inline_surround_toggle = "gs",
				inline_surround_toggle_line = "gss",
				inline_surround_delete = "gsd",
				inline_surround_change = "gsc",
				link_add = "gl",
				link_follow = "gx",
				go_curr_heading = "]h",
				go_parent_heading = "]p",
				go_next_heading = "]]",
				go_prev_heading = "[[",
			},
			inline_surround = {
				emphasis = { key = "i", txt = "*" },
				strong = { key = "b", txt = "**" },
				strikethrough = { key = "s", txt = "~~" },
				code = { key = "c", txt = "`" },
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
		opts = {
			heading = {
				enabled = true,
				sign = true,
				icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
			},
			code = {
				enabled = true,
				sign = true,
				style = "full",
			},
			bullet = { enabled = true },
			checkbox = { enabled = true },
			pipe_table = {
				enabled = true,
				style = "full",
			},
		},
	},
}
