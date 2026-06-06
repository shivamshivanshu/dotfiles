local wezterm = require("wezterm")

local M = {}

function M.apply(config)
	-- Start from the built-ins so default URL detection is preserved
	config.hyperlink_rules = wezterm.default_hyperlink_rules()

	table.insert(config.hyperlink_rules, {
		regex = [[\b\w+://[\w.-]+\.[a-z]{2,15}\S*\b]],
		format = "$0",
	})
end

return M
