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
		init = function()
			vim.api.nvim_create_user_command("MarkdownPreviewToggle", function()
				if package.loaded["livepreview"] and require("livepreview").is_running() then
					vim.cmd("LivePreview close")
				else
					vim.cmd("LivePreview start")
				end
			end, { desc = "Toggle browser live preview of this buffer" })
		end,
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
