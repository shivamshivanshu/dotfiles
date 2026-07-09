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

		{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },
		{ key = "Space", mods = "LEADER", action = act.QuickSelect },

		{ key = "=", mods = "LEADER", action = act.IncreaseFontSize },
		{ key = "-", mods = "LEADER", action = act.DecreaseFontSize },
		{ key = "0", mods = "LEADER", action = act.ResetFontSize },

		-- LEADER+k is pane-up, so clear scrollback moves to CTRL+SHIFT+k
		{ key = "k", mods = "CTRL|SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },

		{ key = "n", mods = "LEADER", action = act.SpawnWindow },

		{ key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "c", mods = "LEADER", action = act.CloseCurrentTab({ confirm = true }) },
		{ key = "1", mods = "LEADER", action = act.ActivateTab(0) },
		{ key = "2", mods = "LEADER", action = act.ActivateTab(1) },
		{ key = "3", mods = "LEADER", action = act.ActivateTab(2) },
		{ key = "4", mods = "LEADER", action = act.ActivateTab(3) },
		{ key = "5", mods = "LEADER", action = act.ActivateTab(4) },
		{ key = "6", mods = "LEADER", action = act.ActivateTab(5) },
		{ key = "7", mods = "LEADER", action = act.ActivateTab(6) },
		{ key = "8", mods = "LEADER", action = act.ActivateTab(7) },
		{ key = "9", mods = "LEADER", action = act.ActivateTab(8) },
		{ key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
		{ key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },

		{ key = "UpArrow", mods = "SHIFT", action = act.ScrollByLine(-1) },
		{ key = "DownArrow", mods = "SHIFT", action = act.ScrollByLine(1) },

		-- ESC+CR = Claude Code newline; tmux extended keys are off (tmux/tmux#4663)
		{ key = "Enter", mods = "SHIFT", action = act.SendString("\x1b\r") },

		-- Splits match the tmux config (| horizontal, % vertical)
		{ key = "|", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "%", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

		{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
		{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
		{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
		{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

		{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "z", mods = "LEADER", action = act.ToggleFullScreen },
	}
end

return M
