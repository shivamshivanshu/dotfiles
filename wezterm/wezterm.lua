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
    ansi          = { "#1d2021","#ea6962","#a9b665","#d8a657","#7daea3","#d3869b","#89b482","#d4be98" },
    brights       = { "#eddeb5","#ea6962","#a9b665","#d8a657","#7daea3","#d3869b","#89b482","#d4be98" },
  },
}
config.color_scheme = "gruvbox_material_dark_hard"

-- Basics ----------------------------------------------------------------------
config.font = wezterm.font("JetBrains Mono")
config.font_size = 14.0
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }

return config
