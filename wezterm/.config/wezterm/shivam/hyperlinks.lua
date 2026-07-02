local wezterm = require("wezterm")

local M = {}

function M.apply(config)
	config.hyperlink_rules = wezterm.default_hyperlink_rules()
end

return M
