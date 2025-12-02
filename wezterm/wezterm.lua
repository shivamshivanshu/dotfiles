local wezterm = require("wezterm")
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- Theme -----------------------------------------------------------------------
config.color_schemes = {
  ["gruvbox_material_dark_hard"] = {
    foreground    = "#D4BE98",
    background    = "#1D2021",
    cursor_bg     = "#D4BE98",
    cursor_border = "#D4BE98",
    cursor_fg     = "#1D2021",
    selection_bg  = "#D4BE98",
    selection_fg  = "#3C3836",
    ansi          = { "#1d2021", "#ea6962", "#a9b665", "#d8a657", "#7daea3", "#d3869b", "#89b482", "#d4be98" },
    brights       = { "#eddeb5", "#ea6962", "#a9b665", "#d8a657", "#7daea3", "#d3869b", "#89b482", "#d4be98" },
  },
}
config.color_scheme = "gruvbox_material_dark_hard"

-- Basics ----------------------------------------------------------------------
config.font = wezterm.font("JetBrains Mono")
config.font_size = 14.0
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }

-- Performance & Scrollback ----------------------------------------------------
config.scrollback_lines = 10000
config.front_end = "OpenGL"

-- macOS specific --------------------------------------------------------------
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Mouse -----------------------------------------------------------------------
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CMD",
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- Visual bell -----------------------------------------------------------------
config.visual_bell = {
  fade_in_duration_ms = 150,
  fade_out_duration_ms = 150,
  target = "CursorColor",
}

-- Leader key (like tmux prefix) -----------------------------------------------
config.leader = { key = "m", mods = "CTRL", timeout_milliseconds = 1000 }

-- Keys ------------------------------------------------------------------------
config.keys = {
  -- Send Ctrl-m to terminal (double press like tmux)
  { key = "m", mods = "LEADER|CTRL", action = wezterm.action.SendKey { key = "m", mods = "CTRL" } },

  -- Reload config (LEADER + r)
  { key = "r", mods = "LEADER", action = wezterm.action.ReloadConfiguration },

  -- Search (without leader)
  { key = "f", mods = "CTRL|SHIFT", action = wezterm.action.Search("CurrentSelectionOrEmptyString") },

  -- Font size (LEADER + =/-/0)
  { key = "=", mods = "LEADER", action = wezterm.action.IncreaseFontSize },
  { key = "-", mods = "LEADER", action = wezterm.action.DecreaseFontSize },
  { key = "0", mods = "LEADER", action = wezterm.action.ResetFontSize },

  -- Clear scrollback (LEADER + k)
  { key = "k", mods = "LEADER", action = wezterm.action.ClearScrollback("ScrollbackAndViewport") },

  -- New window (LEADER + n)
  { key = "n", mods = "LEADER", action = wezterm.action.SpawnWindow },

  -- Tabs (LEADER + t/w/number)
  { key = "t", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "c", mods = "LEADER", action = wezterm.action.CloseCurrentTab{ confirm = true } },
  { key = "1", mods = "LEADER", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "LEADER", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "LEADER", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "LEADER", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "LEADER", action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = "LEADER", action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = "LEADER", action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = "LEADER", action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = "LEADER", action = wezterm.action.ActivateTab(8) },

  -- Tab navigation (LEADER + [/])
  { key = "[", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "]", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },

  -- Scrollback navigation (SHIFT + arrows/PageUp/PageDown - no leader needed)
  { key = "PageUp", mods = "SHIFT", action = wezterm.action.ScrollByPage(-1) },
  { key = "PageDown", mods = "SHIFT", action = wezterm.action.ScrollByPage(1) },
  { key = "UpArrow", mods = "SHIFT", action = wezterm.action.ScrollByLine(-1) },
  { key = "DownArrow", mods = "SHIFT", action = wezterm.action.ScrollByLine(1) },
}

return config
