local wezterm = require("wezterm")
local config = wezterm.config_builder and wezterm.config_builder() or {}

require("shivam.appearance").apply(config)
require("shivam.options").apply(config)
require("shivam.keys").apply(config)

return config
