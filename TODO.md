# TODO

- `cheatsheet.py` has no parser for `aerospace/.config/aerospace/aerospace.toml`, so the
  AeroSpace `alt-*` binds are missing from the cheatsheet. Add a `parse_aerospace()`
  alongside the tmux/wezterm/nvim parsers, macOS-only.

- `cheatsheet.py` hand-maintains buffer-local keybinds in the `_PLUGIN_DEFAULTS` literal
  because its live dump reads `nvim_get_keymap`, which is global-only, so the table drifts
  from the config whenever a buffer-local bind changes. Dump them instead from real buffers
  in the headless instance (`nvim_buf_get_keymap` after setting the filetype, plus a
  grug-far and a diffview buffer) and delete the hardcoded rows.

- Trial `terminalSequence` for the `notify.py` toast: Claude Code 2.1.306 accepts hook JSON
  `{"terminalSequence": "<OSC 9>"}` (allowlist: OSC 0/1/2/9/99/777 and BEL; an OSC 9 body may
  not start with a digit), which would replace the `#{client_tty}`/`/dev/tty` writes and the
  passthrough envelope. Plan: print `json.dumps({"terminalSequence": desktop_toast(toast)})`
  behind a flag, keep the tty path as the fallback. Pass: a WezTerm toast appears for
  permission_prompt and Stop in a plain local session, inside tmux, and over ssh+tmux on the
  remote host, each re-checked after a client detach/re-attach. Only then delete the tty path
  and update the "claude hooks" notes in CLAUDE.md.
