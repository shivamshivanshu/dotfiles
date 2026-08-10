# Dotfiles — working notes for Claude

GNU Stow-managed dotfiles for macOS + Linux. One package per tool; the package tree mirrors
`$HOME` (e.g. `nvim/.config/nvim/` → `~/.config/nvim/`).

## Apply / restow
- `./install_dotfiles.sh link` (idempotent `stow --restow`); `auto` also installs packages.
- Target dirs are usually tree-folded (one dir symlink into this repo), so in-place edits are
  live immediately; added or deleted files still need a restow.

## Verify a change before claiming done
- Shell: `bash -n` and `zsh -n`, then source in a subshell.
- PATH: snapshot all six modes (`zsh`/`bash` × `-lic`/`-ic`/`-c`) before and after, under
  `env -i HOME=$HOME` — an inherited PATH makes the measurement meaningless. Diff entry by
  entry: nothing lost, each of our dirs exactly once.
- nvim: `nvim --headless "+lua require('shivam.<mod>')" +qa` must load clean.
- tmux: parsing is not verification. Unknown options do *not* abort the parse, so a typo or a
  too-new option silently no-ops. Check *resolved* values on a scratch socket
  (`tmux -L t -f tmux/.tmux.conf new-session -d`), diffing `show -g`, `-gw`, `-s`. TPM runs at
  the bottom, so a plugin's unconditional `set` beats anything set earlier.
- TPM reads its plugin list by `cat`ing `~/.tmux.conf` off disk, not from tmux options, so
  `tmux -f /tmp/copy.conf` still loads the *stowed* config's plugins. Isolate by editing the
  real file (symlinked, so edits are live), not a copy.
- Terminal capabilities (`Ms`, `terminal-features`) are built when a client **attaches**;
  `source-file`/`prefix r` does not rebuild them. Nothing clipboard-related is verified until
  the client detaches and re-attaches — on the remote host too.
- aerospace: `aerospace reload-config --dry-run` catches bad commands and unknown keys but needs
  AeroSpace.app running; there is no offline check, so `tomllib` + `--dry-run` is the ceiling.
  `aerospace config --get` only reaches `--major-keys` (`.` and mode tables), not `gaps` etc.
- ssh: diff `ssh -G <host>` for every configured host before and after — only the intended
  keyword deltas may move. `~/.ssh` stays a real dir (keys, known_hosts); only `config` is a link.
- install script: `bash -n`, then `link`, then `tests/install_functions_test.sh` (stubs
  brew/cargo/go/sudo). That test sources everything above the `##### Dispatch #####` banner —
  renaming it breaks the test. For no-op refactors also diff `manual`/`check`/`link` output and
  re-run with `OS="Linux"` forced.
- claude hooks: `python3 -m py_compile claude/.claude/hooks/*.py` first.
  `session_start.py` — pipe sample event JSON in, check `additionalContext` on stdout.
  `notify.py` — stdout is captured, so verify via the `@claude_state` tmux window option instead.
  Its toast goes to tmux's `#{client_tty}`, never `/dev/tty`: hooks can run with no controlling
  terminal, where the `/dev/tty` open failed with ENXIO and was swallowed. Writing to the client
  tty also avoids needing tmux passthrough wrapping.
- Keybind/plugin swaps claiming parity: verify each key's *behaviour* end to end, including
  tmux/pane crossing — not just that the mapping exists.
- After any keybind, alias, or shell-function change: `cheatsheet.py --dump`, confirm the change
  appears, then regenerate with `cheatsheet.py`. Regex parsers cover tmux.conf, alias.sh and
  wezterm keys.lua; nvim binds come from a headless instance, so a config restructure can break
  the dump silently. Keep `desc`s.

## Shell startup files — who owns what
zsh order: `/etc/zshenv`, `~/.zshenv`, `/etc/zprofile`, `~/.zprofile`, `~/.zshrc`, `/etc/zlogin`,
`~/.zlogin`. We own `~/.zshenv`, `~/.zshrc.user`, `~/.zshrc.d/`, `~/.bashrc.user`, `~/.bashrc.d/`.
- `shell/env.sh` is deliberately sourced **twice** on zsh (`.zshenv` + `.zshrc.user`) because
  something always demotes our dirs after `.zshenv`: `path_helper` from `/etc/zprofile`
  everywhere, plus `brew shellenv` in `~/.zprofile` on macOS. The second pass re-promotes them.
  Do not "simplify" either call away.
- Hence its PATH loop **strips then prepends** — skipping dirs already present can fix absence
  but never ordering. The strip is a `while` loop because one `${p//:d:/:}` pass misses *adjacent*
  duplicates, which DevEnv's init really does create.
- `~/.zshenv` must stay silent and cheap: it runs for every zsh including non-interactive ones,
  and stray stdout breaks `scp`/`sftp`.
- Bash gets nothing non-interactively (`bash -c` reads no startup file without `BASH_ENV`), and on
  a box with no `~/.bash_profile` login bash falls through to `~/.profile` and never reaches
  `~/.bashrc` → `.bashrc.user`. Both are known and unfixed.
- Stray `~/*.old` / `*.bak` files mislabel their source (`.zshrc.user.old` held `~/.zshrc`).
  Always `cmp` against the live file before assuming a backup holds your config.

**DevEnv Linux only.** `~/.zshrc`, `~/.zprofile`, `~/.bashrc`, `~/.bash_profile` are
DevEnv-managed and **rewritten on every login shell** (verified: mtimes move after one
`zsh -lic`). Editing them is pointless and they can never be stowed — hook in via the `.user`
files.
- DevEnv's `~/.zprofile` sources `~/.zshrc` itself, so `~/.zshrc` and everything under it runs
  **twice** in login shells — and tmux panes are login shells (`default-command ''` → argv
  `-zsh`). Not fixable from our side.
- `/etc/zlogin.d/devenv_init.d/*` prepends `~/.npm/bin` and `~/.local/bin` after our last chance
  to run, so login PATH leads with `~/.npm/bin` and keeps one duplicate `~/.local/bin`. Accepted;
  a tracked `~/.zlogin` re-sourcing `env.sh` would take the last word back if it ever matters.

**macOS only.** No DevEnv: `~/.zshrc` and `~/.zprofile` are hand-written and ours, and are *not*
rewritten (verified — mtimes unmoved across `zsh -lic`). `~/.zshrc` is deliberately left untracked
as the machine-local hook, since it carries host-specific aliases that must not enter this repo;
its only repo tie is `source ~/.zshrc.user`. There is no `/etc/zshenv` or `/etc/zlogin.d`, so
nothing runs after us.
- `~/.zsh/` holds the zsh-autosuggestions checkout that `zsh/.zshrc.d/config.zsh` sources — it is
  live, not a stray. Only `~/.oh-my-zsh` was unreferenced, and it is gone.
- `~/.zcompcache/` also looks like a stray but is live: Homebrew's completion writes it, and
  nothing here sets `cache-path`, so it stays at the zsh default. The real dump lives at
  `~/.cache/zsh/zcompdump{,.zwc}` per `.zshrc.user`; a `~/.zcompdump` in `$HOME` would be the
  stale one. `~/.zsh_sessions/` was Terminal.app's and is gone — it returns if Terminal.app runs.

## nvim LSP gotchas
- `vim.lsp.config()` merges list fields index-wise with the upstream default — a reordered
  `root_markers` gets mangled; control roots with a `root_dir` function.
- Unmatched `root_markers` still attach the server in single-file mode; the only reliable scope
  gate is a `root_dir` callback that skips `on_dir`.

## tmux clipboard (OSC 52) — do not "simplify" this
- The `Ms` override looks redundant with tmux's builtin `clipboard` terminal-feature. It is not,
  and both halves are load-bearing:
  - It must reference **both** `%p1` and `%p2`. tmux 3.7 passes the selection through `%p1`, and a
    capability ignoring `%p1` makes tmux emit *nothing at all* — no error, no escape, every TERM.
    That killed the old `\E]52;c;%p2%s\007`.
  - The selection field must stay **non-empty**. The builtin emits `\e]52;;<b64>`, which
    mosh-client 1.4.0 silently drops. The conditional (`%?%p1%l%t%p1%s%ec%;`) holds it at `c` when
    tmux passes no flags and forwards an app's own flags untouched, so a nested `\e]52;c;` never
    becomes `\e]52;cc;` (also dropped).
- Direction matters: copy (remote → Mac) is OSC 52 and is what the above fixes. Paste (Mac →
  remote) is ⌘V, which WezTerm injects as bracketed-paste keystrokes — a different path that has
  always worked. Do not "fix" paste.
- WezTerm accepts OSC 52 writes but never answers **reads**, with no option to enable them. Leave
  `get-clipboard` at its 3.7b default `buffer`; `request`/`both` returns nothing. A remote app
  cannot query the Mac clipboard from here.
- Capturing what tmux emits needs a pty with a real winsize — macOS `script` gives 0x0, which
  kills mosh-client with `Error: vector` and yields empty captures that look like "no escape
  emitted". Use a `python3` `openpty` + `TIOCSWINSZ` harness. mosh runs locally without sshd:
  `mosh-server new -i 127.0.0.1 -- <cmd>`, then `MOSH_KEY=... mosh-client`.

## tmux copy mode
- `copy-mode-line-numbers` is **on** (`hybrid`) and the gutter is display-only — tmux maps mouse
  columns through the offset, so a plain drag from column 1 yields the same buffer as with numbers
  off (verified with injected SGR mouse events).
- **Shift-drag is the exception.** We leave `bypass_mouse_reporting_modifiers` unset, so WezTerm
  bypasses tmux's mouse reporting and makes a screen-space selection — grabbing line numbers, pane
  borders and adjacent panes' text. It also reaches the Mac clipboard without OSC 52, so it works
  over ssh regardless of `Ms`. Use a plain drag when you need exact text.
- Application-drawn gutters (nvim `number`, `less -N`, `bat`) are real characters on screen; copy
  mode copies rendered text, so no tmux setting strips them.
- Driving mouse input in a test: write SGR to the client pty (`\e[<0;COL;ROWM` press,
  `\e[<32;COL;ROWM` motion, `\e[<0;COL;ROWm` release). These contain `;`, so a harness that splits
  its script on `;` mangles them into no-ops and produces empty buffers that look like a failed
  selection.

## tmux floating panes — deliberately unused, and why
`prefix *` (`new-pane`, 3.7) is left unbound on purpose. Both blockers are upstream, so the fix is
a tmux upgrade, not config here — re-check both before enabling.
- **Breaks `@continuum-restore`.** A float adds a `<...>` segment to `window_layout` and
  `select-layout` rejects the string tmux just emitted (`invalid layout: ...<40x6,4,2,1>`).
  tmux-resurrect saves and restores via those, so the *whole* window's layout fails, not just the
  float. Re-test: create a float, save `#{window_layout}`, kill it, feed the string back to
  `select-layout`; enable only once that round-trips.
- **Outside our vi navigation model.** `select-pane -L/-D/-U/-R` (what `C-h/j/k/l` run) walks
  tiled geometry, which a float is not part of. Measured: directional keys never reach the float,
  and from inside it all four no-op — for a shell (smart-splits' `@pane-is-vim` false) and for
  nvim (guard true, nvim asks tmux, still no-op). Only `prefix o` and `prefix ;` escape, so
  enabling would mean binding one of those or a `#{pane_floating_flag}`-aware nav binding.
- Lesser limits: mouse-only move/resize, no `resize-pane`, no swap, no float↔tile conversion.
- Copy mode, vi motions and selection all work *inside* a float — the problem is only focus.
- `prefix Enter` (`display-popup -E`) already covers throwaway scratch shells with none of this:
  it is a client overlay, not a pane (never in `list-panes`), so resurrect never sees it.

## Conventions
- Shared shell logic lives in `shell/.config/shell/`, sourced by both bash and zsh — put
  cross-shell code there, never duplicated per shell.
- `claude/.claude/settings.json` is tracked; machine-local overrides go in untracked
  `settings.local.json`. Claude Code writes a real `~/.claude/settings.json` at runtime, so the
  installer removes it (keeping a `.pre-stow` copy if it diverged) to let stow link the tracked one.
- tmux owns panes everywhere; native wezterm splits are unused (LEADER binds only) — don't add
  wezterm-side nav integrations.
- On macOS `alt-*` belongs to AeroSpace (i3-style, `alt` is `$mod`) and is grabbed system-wide, so
  never bind Alt in nvim, tmux or wezterm. Alt+arrows is the one exception, reserved for
  smart-splits resize. The gaps versus i3 are deliberate: no alt-arrow focus aliases (they collide
  with that resize binding), `alt-w` is accordion (AeroSpace has no tabbed layout), no
  `split h`/`split v` (i3-compat only, and `enable-normalization-flatten-containers` undoes it —
  use `join-with`), no `$mod+d` launcher (cmd-space covers it).
- An unpinned aerospace workspace attaches to the *main* monitor, not the focused one, so
  `workspace-to-monitor-force-assignment` is what keeps windows off the laptop screen. Use
  case-insensitive name substrings with `'main'` as the undocked fallback — never the numeric
  monitor patterns, which are left-to-right positions and renumber on undock.
- smart-splits must stay `lazy = false`: it sets tmux's `@pane-is-vim` at startup, before the
  first nav key arrives. Lazy-loading it breaks `C-h/j/k/l` routing until the plugin loads.
