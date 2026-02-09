return {
	{
		"tadmccorkle/markdown.nvim",
		ft = "markdown",
		opts = {
			mappings = {
				inline_surround_toggle = "gs",
				inline_surround_toggle_line = "gss",
				inline_surround_delete = "ds",
				inline_surround_change = "cs",
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
			on_attach = function(bufnr)
				local map = vim.keymap.set
				map("n", "<leader>ml", "<cmd>MDListItemBelow<CR>", { buffer = bufnr, desc = "Add list item below" })
				map("n", "<leader>mL", "<cmd>MDListItemAbove<CR>", { buffer = bufnr, desc = "Add list item above" })
				map("n", "<leader>mc", "<cmd>MDTaskToggle<CR>", { buffer = bufnr, desc = "Toggle task checkbox" })
				map("x", "<leader>mc", ":MDTaskToggle<CR>", { buffer = bufnr, desc = "Toggle task checkboxes" })
			end,
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = "markdown",
		build = "cd app && npx --yes yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Toggle markdown preview" },
		},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = "markdown",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{ "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", ft = "markdown", desc = "Toggle render markdown" },
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
