local wezterm = require("wezterm")

local M = {}

local MAC_SOUND = { "afplay", "/System/Library/Sounds/Glass.aiff" }
local LINUX_SOUND = { "paplay", "/usr/share/sounds/freedesktop/stereo/complete.oga" }

function M.apply(config)
	-- Play a distinct sound instead of the system beep so a bell is
	-- recognisable as Claude (the only regular bell source).
	config.audible_bell = "Disabled"

	local play = wezterm.target_triple:find("apple") and MAC_SOUND or LINUX_SOUND
	wezterm.on("bell", function()
		wezterm.background_child_process(play)
	end)
end

return M
