local wezterm = require("wezterm")

local M = {}

function M.apply(config)
	config.term = "xterm-256color"

	config.scrollback_lines = 10000
	config.front_end = "WebGpu"
	config.max_fps = 120

	config.send_composed_key_when_left_alt_is_pressed = false
	config.send_composed_key_when_right_alt_is_pressed = false

	-- Kitty keyboard protocol lets apps (e.g. Claude Code) distinguish Shift+Enter from Enter
	config.enable_kitty_keyboard = true

	config.mouse_bindings = {
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CMD",
			action = wezterm.action.OpenLinkAtMouseCursor,
		},
	}
end

return M
