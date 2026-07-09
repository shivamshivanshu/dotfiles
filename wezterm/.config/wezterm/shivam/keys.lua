local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply(config)
	-- Leader key, like the tmux prefix
	config.leader = { key = "m", mods = "CTRL", timeout_milliseconds = 1000 }

	config.keys = {
		-- Double-press leader to send a literal Ctrl-m through
		{ key = "m", mods = "LEADER|CTRL", action = act.SendKey({ key = "m", mods = "CTRL" }) },

		-- tmux owns panes; both mod spellings cover wezterm's SHIFT normalization
		{ key = '"', mods = "CTRL|SHIFT|ALT", action = act.DisableDefaultAssignment },
		{ key = '"', mods = "CTRL|ALT", action = act.DisableDefaultAssignment },
		{ key = "%", mods = "CTRL|SHIFT|ALT", action = act.DisableDefaultAssignment },
		{ key = "%", mods = "CTRL|ALT", action = act.DisableDefaultAssignment },

		-- Tab bar is off, so stock tab keys would switch to invisible tabs
		{ key = "t", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
		{ key = "t", mods = "SUPER", action = act.DisableDefaultAssignment },
		{ key = "w", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
		{ key = "w", mods = "SUPER", action = act.DisableDefaultAssignment },
		{ key = "PageUp", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
		{ key = "PageDown", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },

		{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },
		{ key = "Space", mods = "LEADER", action = act.QuickSelect },

		{ key = "=", mods = "LEADER", action = act.IncreaseFontSize },
		{ key = "-", mods = "LEADER", action = act.DecreaseFontSize },
		{ key = "0", mods = "LEADER", action = act.ResetFontSize },

		{ key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

		-- ESC+CR = Claude Code newline; tmux extended keys are off (tmux/tmux#4663)
		{ key = "Enter", mods = "SHIFT", action = act.SendString("\x1b\r") },
	}
end

return M
