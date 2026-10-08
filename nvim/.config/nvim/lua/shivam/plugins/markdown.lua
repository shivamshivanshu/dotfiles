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
actions.add("markdown.list_item_above", md_cmd("MDListItemAbove"), { desc = "Insert list item above" })
actions.add("markdown.task_toggle", md_cmd("MDTaskToggle"), { desc = "Toggle task checkbox" })
actions.add("markdown.renumber_list", md_cmd("MDResetListNumbering"), { desc = "Renumber ordered list" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	group = vim.api.nvim_create_augroup("shivam-markdown-keys", { clear = true }),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		actions.map("n", "<localleader>l", "markdown.list_item_below", opts)
		actions.map("n", "<localleader>L", "markdown.list_item_above", opts)
		actions.map("n", "<localleader>t", "markdown.task_toggle", opts)
		actions.map("n", "<localleader>n", "markdown.renumber_list", opts)
		vim.keymap.set("x", "<localleader>t", ":MDTaskToggle<CR>", {
			buffer = ev.buf,
			desc = "Toggle task checkboxes (range)",
		})
	end,
})

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
