local actions = require("shivam.util.actions")

actions.add("calendar.open", function()
	vim.cmd("Calendar")
end, { desc = "Open monthly calendar" })

return {
	"wsdjeg/calendar.nvim",
	cmd = "Calendar",
	opts = {},
}
