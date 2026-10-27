# TODO

- `cheatsheet.py` has no parser for `aerospace/.config/aerospace/aerospace.toml`, so the
  AeroSpace `alt-*` binds are missing from the cheatsheet. Add a `parse_aerospace()`
  alongside the tmux/wezterm/nvim parsers; like `parse_wezterm`, it parses the repo file on
  every host, with the section labelled macOS-only.

- `cheatsheet.py` hand-maintains buffer-local keybinds in the `_PLUGIN_DEFAULTS` literal
  because its live dump reads `nvim_get_keymap`, which is global-only, so the table drifts
  from the config whenever a buffer-local bind changes. Dump them instead from real buffers
  in the headless instance (`nvim_buf_get_keymap` after setting the filetype, plus a
  grug-far and a diffview buffer) and delete the hardcoded rows the dump now covers; keep
  any it cannot reach.

- Paused toast trial in `claude/.claude/hooks/notify.py`: `CLAUDE_NOTIFY_TOAST_VIA=hook-output`
  prints `{"terminalSequence": "<OSC 9>"}` for Claude Code to emit, instead of writing tmux's
  `#{client_tty}`. Byte capture (claude_notes/scratchpad/20261021/terminal-sequence-trial/)
  passed for a visible pane only; with `allow-passthrough on` tmux drops passthrough from a
  pane that is not visible (`man tmux`), which is when a toast matters. Adopting it needs
  `allow-passthrough all` (any hidden pane can then pass raw escapes to the terminal) plus the
  visual check locally, over ssh+tmux and after a re-attach; otherwise delete the flag branch.
