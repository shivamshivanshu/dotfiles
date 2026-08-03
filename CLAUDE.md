# Dotfiles — working notes for Claude

GNU Stow-managed dotfiles for macOS + Linux. One package per tool; the package
tree mirrors `$HOME` (e.g. `nvim/.config/nvim/` → `~/.config/nvim/`).

## Apply / restow
- Link everything: `./install_dotfiles.sh link` (idempotent `stow --restow`).
- Full setup incl. packages: `./install_dotfiles.sh auto`.
- Target dirs are usually tree-folded (a single dir symlink into this repo), so
  in-place edits are live immediately; new or deleted files still need a restow.

## Verify a change before claiming done
- Shell: `bash -n <file>` and `zsh -n <file>`; source in a subshell to confirm no errors.
- nvim: `nvim --headless "+lua require('shivam.<mod>')" +qa` must load clean.
- tmux: `tmux -f tmux/.tmux.conf new-session -d -s _t \; kill-session -t _t`.
- ssh: capture `ssh -G <host>` for every configured host before and after; the diff must show
  only the intended keyword deltas. `~/.ssh` must stay a real dir with keys and known_hosts
  untouched — only `config` is a symlink into the repo.
- install script: `bash -n install_dotfiles.sh`, then `./install_dotfiles.sh link`, then
  `tests/install_functions_test.sh` (stubs brew/cargo/go/sudo, so it covers the install
  paths without touching the system). That test sources everything above the
  `##### Dispatch #####` banner — renaming that banner breaks it.
  For changes that shouldn't alter behaviour, diff `manual`/`check`/`link` output before
  and after, and re-run with `OS="Linux"` forced to exercise the non-macOS path.
- claude hooks: `python3 -m py_compile claude/.claude/hooks/*.py` first.
- `session_start.py`: pipe sample event JSON in, check emitted additionalContext
  on stdout. `notify.py`: stdout is captured — verify via the `@claude_state`
  tmux window option, not stdout. Its desktop toast goes to tmux's
  `#{client_tty}`, never `/dev/tty`: a hook can run with no controlling
  terminal, and the old `/dev/tty` open failed with ENXIO and was swallowed,
  losing the toast silently. Writing to the client tty also means the OSC needs
  no tmux passthrough wrapping.
- Plugin/keybind swaps promising parity: verify each key's *behaviour* end to end
  (including tmux/pane crossing), not just that the mapping exists.
- After changing any keybind, alias, or shell function: run `cheatsheet.py --dump`
  and confirm the change appears (the regex parsers cover tmux.conf/alias.sh/wezterm
  keys.lua, while nvim binds/commands are dumped from a headless nvim instance —
  a config restructure can silently break them; descs must be kept); regenerate
  with `cheatsheet.py`.

## nvim LSP gotchas
- `vim.lsp.config()` merges list fields index-wise with the upstream default —
  a reordered `root_markers` gets mangled; control roots with a `root_dir` function.
- Unmatched `root_markers` still attach the server in single-file mode; the only
  reliable scope gate is a `root_dir` callback that skips `on_dir`.

## Conventions
- Shared shell logic lives in `shell/.config/shell/` and is sourced by both bash
  and zsh — put cross-shell code there, never duplicated per shell.
- `claude/.claude/settings.json` is tracked (universal); machine-local overrides
  go in untracked `settings.local.json`. Claude Code writes a real
  `~/.claude/settings.json` at runtime; the installer removes it (keeping a
  `.pre-stow` copy if it diverged) so stow can symlink the tracked one.
- Split navigation: tmux owns panes everywhere; native wezterm splits are unused
  (LEADER binds only) — don't add wezterm-side nav integrations.
- On macOS `alt-*` belongs to AeroSpace (i3-style keymap, `alt` is `$mod`) — it grabs
  those keys system-wide before any terminal sees them, so never bind Alt in nvim, tmux
  or wezterm. Alt+arrows is the one exception, reserved for smart-splits resize.
  The gaps versus i3 are deliberate, not oversights: no alt-arrow focus aliases (they
  would collide with that resize binding), `alt-w` is accordion because AeroSpace has no
  tabbed layout, no `split h`/`split v` (no such command — `join-with` is the inverse),
  and no `$mod+d` launcher (cmd-space covers it).
- smart-splits must stay `lazy = false`: it sets tmux's `@pane-is-vim` at
  startup, before the first nav key arrives. Never lazy/keys-gate it for
  startup perf — that breaks C-h/j/k/l routing until the plugin loads.
