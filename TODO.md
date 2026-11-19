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

- Unverified: the codex `PermissionRequest` hook (tmux `◐` waiting state). imc-codex rejects
  `-a untrusted` ("Cannot use -a untrusted while sandboxed; sandbox escalation is disabled"), so
  no approval prompt could be raised to measure it; check on the next real codex approval.

- Codex reads `~/.claude/agents/{verifier,simple-implementer}.md` as role briefs (AGENTS.md
  Harness mechanics, `agent role`), so it depends on the claude package being stowed. Move both
  into `agents/.agents/agents/` with tracked symlinks back from `claude/.claude/agents/`.

- README's One-time migration snippet is run by hand on each host after skills move to
  `agents/`. Have `prepare_claude` (install_dotfiles.sh) remove old per-file skill dirs whose
  only entry is a `SKILL.md` link, and prune dangling links into the repo, then drop the snippet.
