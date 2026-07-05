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
- install script: `bash -n install_dotfiles.sh`, then `./install_dotfiles.sh link`.
- Plugin/keybind swaps promising parity: verify each key's *behaviour* end to end
  (including tmux/pane crossing), not just that the mapping exists.

## nvim LSP gotchas
- `vim.lsp.config()` merges list fields index-wise with the upstream default —
  a reordered `root_markers` gets mangled; control roots with a `root_dir` function.
- Unmatched `root_markers` still attach the server in single-file mode; the only
  reliable scope gate is a `root_dir` callback that skips `on_dir`.

## Conventions
- Shared shell logic lives in `shell/.config/shell/` and is sourced by both bash
  and zsh — put cross-shell code there, never duplicated per shell.
- `claude/.claude/settings.json` is tracked (universal); machine-local overrides
  go in untracked `settings.local.json`. The installer drops a runtime-written
  `~/.claude/settings.json` so the tracked one links.
- Comments only for a non-obvious *why*; never restate code.
- Atomic commits; commit only when asked.
- Split navigation: tmux owns panes everywhere; native wezterm splits are unused
  (LEADER binds only) — don't add wezterm-side nav integrations.
