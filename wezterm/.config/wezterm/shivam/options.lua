local wezterm = require("wezterm")

local M = {}

function M.apply(config)
	config.audible_bell = "Disabled"

	config.scrollback_lines = 10000
	config.max_fps = 120

	config.check_for_updates = false

	config.quick_select_patterns = {
		[[\S+\.(?:cpp|cc|cxx|h|hpp|py|lua|sh):\d+(?::\d+)?]],
	}

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
