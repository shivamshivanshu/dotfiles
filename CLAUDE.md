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
- tmux: `tmux -f tmux/.tmux.conf new-session -d -s _t \; kill-session -t _t` only proves the
  file parses. Unknown options do *not* abort parsing (later lines still apply), so a typo or a
  too-new option silently no-ops. Check resolved values on a scratch socket
  (`tmux -L t -f tmux/.tmux.conf new-session -d`) and diff `show -g`, `-gw` and `-s` before and
  after. A value set in the file is not the final value: TPM runs at the *bottom*, so a plugin's
  unconditional `set` beats anything set earlier (this is how tmux-sensible silently held
  `status-keys` at emacs for months).
- TPM builds its plugin list by `cat`ing `~/.tmux.conf` off disk, not by reading tmux options, so
  `tmux -f /tmp/other.conf` still loads whatever the *stowed* config lists. Isolating a plugin by
  editing a copy does not work — edit the real file (it is symlinked, so the change is live).
- Terminal capabilities (`Ms`, `terminal-features`) are built when a client **attaches**.
  `source-file`/`prefix r` does not rebuild them, so nothing clipboard-related is verified until
  the client detaches and re-attaches — on the remote host too, not just locally.
- aerospace: `aerospace reload-config --dry-run` validates command spellings and unknown
  keys, but only with AeroSpace.app running — there is no offline config check, so a
  `tomllib`/`--dry-run` pair is the most you can do. `aerospace config --get <key>` only
  introspects the keys listed by `--major-keys` (`.` and the mode tables), not `gaps` etc.
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

## tmux clipboard (OSC 52) — do not "simplify" this
- The `Ms` override in `tmux.conf` looks redundant with tmux's builtin `clipboard`
  terminal-feature. It is not, and both halves of it are load-bearing:
  - It must reference **both** `%p1` and `%p2`. tmux 3.7 started passing the selection through
    `Ms`'s first parameter, and a capability that ignores `%p1` makes tmux emit *nothing at all*
    — no error, no escape, for every TERM. The old `\E]52;c;%p2%s\007` was dead for this reason.
  - The selection field must stay **non-empty**. Dropping the override and using the builtin
    feature emits `\e]52;;<b64>`, which mosh-client 1.4.0 silently drops on the floor. The
    conditional (`%?%p1%l%t%p1%s%ec%;`) keeps it at `c` when tmux passes no flags and forwards an
    app's own flags untouched, so a nested `\e]52;c;` does not become `\e]52;cc;` (mosh drops that
    too).
- Direction matters. Copy (remote → Mac) goes over OSC 52 and is what the above fixes. Paste
  (Mac → remote) is ⌘V, which WezTerm injects as bracketed-paste *keystrokes* — a different path
  entirely, and it has always worked. Do not "fix" paste.
- WezTerm accepts OSC 52 writes but never answers OSC 52 **reads**, and has no option to enable
  them. So leave `get-clipboard` at its 3.7b default of `buffer`; `request`/`both` returns nothing
  and is a strict regression. A remote app cannot query the Mac clipboard from here.
- Capturing what tmux actually emits needs a pty with a real winsize. macOS `script` gives 0x0,
  which makes mosh-client die with `Error: vector` and yields empty captures that look like
  "no escape emitted". Use a `python3` `openpty` + `TIOCSWINSZ` harness. mosh can be exercised
  locally without sshd: `mosh-server new -i 127.0.0.1 -- <cmd>`, then `MOSH_KEY=... mosh-client`.
## tmux copy mode
- `copy-mode-line-numbers` is **on** (`hybrid`), and the gutter is display-only — it does not end
  up in copied text. Verified by injecting real SGR mouse events into a client: the gutter renders
  as a 4-column prefix (`  3 ALPHA-ONE`), yet a drag from column 1, single-line or multi-line,
  yields exactly the same buffer as with numbers off. tmux maps mouse columns through the offset.
- The one gesture that *does* capture the gutter is **shift-drag**. We do not set
  `bypass_mouse_reporting_modifiers`, so WezTerm's default lets Shift+drag bypass tmux's mouse
  reporting and make a WezTerm-local, screen-space selection — that grabs the line numbers, along
  with pane borders and adjacent panes' text if it spans a split. It also goes straight to the Mac
  clipboard without OSC 52, so it works over ssh regardless of the `Ms` capability. Use a plain
  drag (tmux copy mode) when you need exact text.
- The other source of line numbers in copied text is the application drawing its own gutter (nvim
  `number`/`relativenumber`, `less -N`, `bat`): tmux copy mode copies rendered screen text, so
  those are real characters in the pane and no tmux setting will strip them.
- Driving mouse input for a test: write SGR sequences to the client pty
  (`\e[<0;COL;ROWM` press, `\e[<32;COL;ROWM` motion, `\e[<0;COL;ROWm` release). Beware that these
  contain `;` — a harness that splits its script on `;` will silently mangle them into no-ops and
  produce empty buffers that look like "the drag selected nothing".

## tmux floating panes — deliberately unused, and why
`prefix *` (`new-pane`, 3.7) is a tmux default binding we leave unused. It is not an oversight;
two things break, both measured. If a future session wants to enable it, re-check both first —
they are upstream bugs/gaps, so the fix is a tmux upgrade, not a config change here.
- **Breaks `@continuum-restore`.** A floating pane adds a `<...>` segment to `window_layout`, and
  `select-layout` rejects the very string tmux just emitted (`invalid layout: ...<40x6,4,2,1>`).
  tmux-resurrect saves `window_layout` and restores via `select-layout`, so the *whole* window's
  layout fails to restore, not just the float. Re-test with: create a float, save
  `#{window_layout}`, kill the float, feed the string back to `select-layout`. Enable only once
  that round-trips.
- **Outside our vi navigation model.** `select-pane -L/-D/-U/-R` (what `C-h/j/k/l` run) walks the
  tiled layout geometry, which a float is not part of. Measured: directional keys never reach the
  float from a tiled pane, and from inside the float all four are no-ops in every direction — so
  it is a dead end both ways, whether it runs a shell (smart-splits' `@pane-is-vim` guard is
  false, `select-pane` no-ops) or nvim (guard true, nvim asks tmux, `select-pane` no-ops). Escape
  hatches that do work: `prefix o` (`select-pane -t :.+`, cycles through the float) and
  `prefix ;` (`last-pane`). Enabling the feature would mean binding one of those, or a
  `#{pane_floating_flag}`-aware nav binding, so focus is never trapped.
- Not blockers, just current limits: mouse-only move/resize, no `resize-pane`, no swap, no
  float↔tile conversion.
- What *does* work inside a float: copy mode with `mode-keys vi`, vi motions, selection and copy —
  verified. The problem is only getting focus in and out.
- `prefix Enter` (`display-popup -E`) already covers the throwaway-scratch-shell case and has none
  of this: it is a client overlay, not a pane (never in `list-panes`, `#{window_panes}` unchanged),
  so resurrect never sees it and navigation never has to reach it.

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
  tabbed layout, no `split h`/`split v` (the `split` command exists but is i3-compat only
  and `enable-normalization-flatten-containers` undoes it — use `join-with`), and no
  `$mod+d` launcher (cmd-space covers it).
- An unpinned aerospace workspace attaches to the *main* monitor, not the focused one, so
  `workspace-to-monitor-force-assignment` is what keeps windows off the laptop screen.
  Use case-insensitive name substrings with `'main'` as a second pattern for the undocked
  fallback — never the numeric monitor patterns, which are left-to-right positions and
  renumber on undock.
- smart-splits must stay `lazy = false`: it sets tmux's `@pane-is-vim` at
  startup, before the first nav key arrives. Never lazy/keys-gate it for
  startup perf — that breaks C-h/j/k/l routing until the plugin loads.
