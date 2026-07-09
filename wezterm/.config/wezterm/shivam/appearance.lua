local wezterm = require("wezterm")

local M = {}

function M.apply(config)
	config.color_schemes = {
		["gruvbox_dark"] = {
			foreground = "#ebdbb2",
			background = "#282828",
			cursor_bg = "#ebdbb2",
			cursor_border = "#ebdbb2",
			cursor_fg = "#282828",
			selection_bg = "#458588",
			selection_fg = "#ebdbb2",
			ansi = { "#282828", "#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#a89984" },
			brights = { "#928374", "#fb4934", "#b8bb26", "#fabd2f", "#83a598", "#d3869b", "#8ec07c", "#ebdbb2" },
		},
	}
	config.color_scheme = "gruvbox_dark"

	config.font = wezterm.font("JetBrainsMono Nerd Font")
	config.font_size = 12.5

	config.hide_tab_bar_if_only_one_tab = false
	config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }

	config.default_cursor_style = "BlinkingBlock"
	config.cursor_blink_rate = 600
	config.window_background_opacity = 0.97
	config.macos_window_background_blur = 20
end

return M
