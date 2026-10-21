# TODO

- `cheatsheet.py` has no parser for `aerospace/.config/aerospace/aerospace.toml`, so the
  AeroSpace `alt-*` binds are missing from the cheatsheet. Add a `parse_aerospace()`
  alongside the tmux/wezterm/nvim parsers, macOS-only.

- `cheatsheet.py` hand-maintains buffer-local keybinds in the `_PLUGIN_DEFAULTS` literal
  because its live dump reads `nvim_get_keymap`, which is global-only, so the table drifts
  from the config whenever a buffer-local bind changes. Dump them instead from real buffers
  in the headless instance (`nvim_buf_get_keymap` after setting the filetype, plus a
  grug-far and a diffview buffer) and delete the hardcoded rows.

- Finish the `terminalSequence` toast trial. `CLAUDE_NOTIFY_TOAST_VIA=hook-output` makes
  `notify.py` print `{"terminalSequence": "<OSC 9>"}` instead of writing a tty. Byte capture
  (Claude Code 2.1.306, tmux 3.7b; claude_notes/scratchpad/20261021/terminal-sequence-trial/
  results.md): Claude Code wraps it in `ESC Ptmux;` itself, and tmux unwraps it to a raw OSC 9
  on the client — outside tmux, inside tmux and after detach/re-attach. It is dropped with
  `allow-passthrough off`, a dependency the client-tty path does not have. Left: the visual
  check — launch `CLAUDE_NOTIFY_TOAST_VIA=hook-output claude` and confirm a WezTerm toast on
  permission_prompt and Stop locally in tmux and over ssh+tmux on the remote host, also after
  a re-attach. Pass → make it the only path: delete `emit_toast`/`client_tty`/
  `terminal_sequence` and the flag, and rewrite the "claude hooks" notes in CLAUDE.md
  (passthrough now required).
