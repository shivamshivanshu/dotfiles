local actions = require("shivam.util.actions")

actions.add("toggle.markdown_preview", function()
	if package.loaded["livepreview"] and require("livepreview").is_running() then
		vim.cmd("LivePreview close")
	else
		vim.cmd("LivePreview start")
	end
end, { desc = "Toggle browser live preview of this buffer", cmd = "MarkdownPreviewToggle" })

-- markdown.nvim creates its MD* commands buffer-locally on attach
local function md_cmd(cmd)
	return function()
		if vim.bo.filetype ~= "markdown" then
			vim.notify(cmd .. " works in markdown buffers only", vim.log.levels.WARN)
			return
		end
		vim.cmd(cmd)
	end
end

actions.add("markdown.list_item_below", md_cmd("MDListItemBelow"), { desc = "Insert list item below" })
actions.map("n", "<leader>ml", "markdown.list_item_below")

actions.add("markdown.list_item_above", md_cmd("MDListItemAbove"), { desc = "Insert list item above" })
actions.map("n", "<leader>mL", "markdown.list_item_above")

actions.add("markdown.task_toggle", md_cmd("MDTaskToggle"), { desc = "Toggle task checkbox" })
actions.map("n", "<leader>mt", "markdown.task_toggle")
vim.keymap.set("x", "<leader>mt", ":MDTaskToggle<CR>", { desc = "Toggle task checkboxes (range)" })

actions.add("markdown.renumber_list", md_cmd("MDResetListNumbering"), { desc = "Renumber ordered list" })
actions.map("n", "<leader>mn", "markdown.renumber_list")

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
