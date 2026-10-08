# TODO

- `cheatsheet.py` has no parser for `aerospace/.config/aerospace/aerospace.toml`, so the
  AeroSpace `alt-*` binds are missing from the cheatsheet. Add a `parse_aerospace()`
  alongside the tmux/wezterm/nvim parsers, macOS-only.

- `cheatsheet.py` hand-maintains buffer-local keybinds in the `_PLUGIN_DEFAULTS` literal
  because its live dump reads `nvim_get_keymap`, which is global-only, so the table drifts
  from the config whenever a buffer-local bind changes. Dump them instead from real buffers
  in the headless instance (`nvim_buf_get_keymap` after setting the filetype, plus a
  grug-far and a diffview buffer) and delete the hardcoded rows.
