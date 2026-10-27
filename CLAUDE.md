# Dotfiles — working notes for Claude

GNU Stow-managed dotfiles for macOS + Linux. One package per tool; the package tree mirrors
`$HOME` (e.g. `nvim/.config/nvim/` → `~/.config/nvim/`).

## Apply / restow
- `./install_dotfiles.sh link` (idempotent `stow --restow`); `auto` also installs packages.
  Before stowing, `link` moves a divergent real `~/.ssh/config`, `~/.zshenv` or (Linux)
  `~/.config/rtk/config.toml` to `<name>.pre-stow`; an identical one is deleted.
- Target dirs are tree-folded (one dir symlink into this repo), except in the `--no-folding`
  packages `claude`, `codex`, `rtk`, `ssh`, where each file is its own link. Either way in-place
  edits are live immediately; added or deleted files need a restow.

## tmux from source (Linux)
Distro tmux is below `MIN_TMUX_VERSION` (EL9 dnf 3.2a, 3.5a on DevEnv; Ubuntu 24.04 3.4), so
`auto`/`check` fail their tmux check there; build by hand into `~/.local`, whose `bin` precedes the
system dirs on PATH:
- Deps: libevent and ncurses dev packages, autoconf, automake, bison, pkg-config.
- Build from a git tag: GitHub release tarballs hang from DevEnv boxes, while `git clone` works.
  `sh autogen.sh && ./configure --prefix=$HOME/.local --disable-debug --enable-optimizations`,
  then `make -j"$(nproc)" install`.
- DevEnv quirk: `/usr/lib64/libtinfo.so` points at `libtinfo.so.5.9` while the headers are
  ncurses 6.2, so a plain configure links v5. Add `LIBTINFO_LIBS="-l:libtinfo.so.6"`; check with
  `ldd "$(command -v tmux)" | grep tinfo`.
- Rename the old binary (`mv tmux tmux-<old>`) before installing: a running server keeps the old
  inode, and a client of the same `PROTOCOL_VERSION` keeps talking to it until `kill-server`.

## Verify a change before claiming done
- `$HOME` links resolve to the stowed checkout (`readlink ~/.tmux.conf`), not a worktree, so from
  another worktree point each tool at the tree under test: nvim `XDG_CONFIG_HOME=$PWD/nvim/.config`
  (measured: `stdpath('config')` is the worktree, plugins still load); tmux/TPM and rtk a scratch
  `XDG_CONFIG_HOME` (below); `scripts/.local/bin/cheatsheet.py` by repo path (it finds the repo
  from `__file__`; its nvim dump honours `XDG_CONFIG_HOME`). Never `link` against the real `$HOME`
  from a worktree: the `prepare_*` steps move live files to `.pre-stow` before stow aborts on the
  foreign links. Use `HOME=$(mktemp -d) ./install_dotfiles.sh link` (its `stow_packages` measured
  from a worktree: every package stows clean, `rtk`/`claude` stay unfolded, `settings.json` is a
  copy; `link` also sets `core.hooksPath` in the shared repo config, to the same value).
- Shell: `bash -n` and `zsh -n`, then source in a subshell.
- PATH: snapshot all six modes (`zsh`/`bash` × `-lic`/`-ic`/`-c`) before and after, under
  `env -i HOME=$HOME` — an inherited PATH makes the measurement meaningless. Diff entry by
  entry: nothing lost, each of our dirs exactly once.
- nvim: `nvim --headless "+lua require('shivam.<mod>')" +qa` must load clean.
- tmux: parsing is not verification. Unknown options do *not* abort the parse, so a typo or a
  too-new option silently no-ops. Check *resolved* values on a scratch socket
  (`tmux -L t -f tmux/.tmux.conf new-session -d` from the repo root, `tmux -L t kill-server`
  after), diffing `show -g`, `-gw`, `-s`. TPM runs at the bottom, so a plugin's unconditional
  `set` beats anything set earlier.
- TPM reads its plugin list by `cat`ing `${XDG_CONFIG_HOME:-~/.config}/tmux/tmux.conf` if it
  exists, else `~/.tmux.conf`, off disk — not from tmux options — so `tmux -f /tmp/copy.conf`
  still loads the *stowed* config's plugins. Isolate by starting the scratch server with
  `XDG_CONFIG_HOME=<scratch>` whose `tmux/tmux.conf` is the file under test (measured: its
  plugins load), or by editing the real file (symlinked, so edits are live) — never a bare
  `-f` copy.
- Terminal capabilities (`Ms`, `terminal-features`) are built when a client **attaches**;
  `source-file`/`prefix r` does not rebuild them. Nothing clipboard-related is verified until
  the client detaches and re-attaches — on the remote host too.
- aerospace: `aerospace reload-config --dry-run` catches bad commands and unknown keys but needs
  AeroSpace.app running; there is no offline check, so `tomllib` + `--dry-run` is the ceiling.
  `aerospace config --get` only reaches `--major-keys` (`.` and mode tables), not `gaps` etc.
- ssh: diff `ssh -G <host>` for every configured host before and after — only the intended
  keyword deltas may move. `~/.ssh` stays a real dir (keys, known_hosts); only `config` is a link.
- install script: `bash -n`, then `link` (from a worktree, only as
  `HOME=$(mktemp -d) ./install_dotfiles.sh link`), then `tests/install_functions_test.sh` (stubs
  brew/cargo/go/sudo). That test sources everything above the `##### Dispatch #####` banner —
  renaming it breaks the test. For no-op refactors also diff `manual`/`check`/`link` output, and
  `manual`/`check` with the other platform forced. `OS` is assigned from `uname -s`, so an env
  var does nothing: `bash <(sed 's/^OS=.*/OS="Darwin"/' install_dotfiles.sh) manual` (`"Linux"`
  on macOS). `$0` is then `/dev/fd/N`, so never `link` this way.
- Parse checks for packages without their own bullet: `git config -f git/.gitconfig -l >/dev/null`;
  `python3 -m py_compile scripts/.local/bin/cheatsheet.py`; `python3 -m json.tool` on
  `claude/.claude/settings.json` and `claude/.claude/keybindings.json`; wezterm `luac -p` one file
  at a time (luac 5.4.4 aborts with "double free" given several), plus on macOS
  `wezterm --config-file wezterm/.config/wezterm/wezterm.lua show-keys` (unmeasured). `dnf` and
  `alacritty` (unused) have none.
- claude hooks: `python3 -m py_compile claude/.claude/hooks/*.py` first.
  `session_start.py` — pipe sample event JSON in, check `additionalContext` on stdout.
  `notify.py` — stdout is captured, so verify via the `@claude_state` tmux window option instead.
  Inside tmux its toast goes to `#{client_tty}`; `/dev/tty` only outside tmux (why: `emit_toast`
  in notify.py).
  It assumes one Claude session per tmux window: state is a window option, so a second session
  or a nested `claude -p` in that window overwrites it — accepted.
- codex profile: `codex -p claude debug prompt-input x </dev/null` parses it (rejects bad TOML and
  bad value types) and renders what codex is told, offline. Unknown keys pass silently there.
- Keybind/plugin swaps claiming parity: verify each key's *behaviour* end to end, including
  tmux/pane crossing — not just that the mapping exists.
- After any keybind, alias, or shell-function change: `scripts/.local/bin/cheatsheet.py --dump`,
  confirm the change appears, then regenerate with `cheatsheet.py`. Regex parsers cover
  tmux.conf, alias.sh, worktree.sh functions, fzf.sh and keybinds.zsh binds, and wezterm
  keys.lua; nothing parses aerospace.toml (TODO.md). nvim global binds come from a headless
  instance, so a config restructure can break the dump silently; buffer-local plugin binds are
  the hand-kept `_PLUGIN_DEFAULTS` table. Keep `desc`s.

## Shell startup files — who owns what
zsh order: `/etc/zshenv`, `~/.zshenv`, `/etc/zprofile`, `~/.zprofile`, `/etc/zshrc`, `~/.zshrc`,
`/etc/zlogin`, `~/.zlogin`. We own `~/.zshenv`, `~/.zshrc.user`, `~/.zshrc.d/`, `~/.bashrc.user`,
`~/.bashrc.d/`.
- `shell/.config/shell/env.sh` is deliberately sourced **twice** on zsh (`.zshenv` +
  `.zshrc.user`) because something always demotes our dirs after `.zshenv` — macOS: `path_helper`
  from `/etc/zprofile` and `brew shellenv` in `~/.zprofile`; DevEnv Linux:
  `/etc/profile.d/devenv_init.d/*`, which `~/.zshrc` sources before `.zshrc.user`. The second
  pass re-promotes them. Do not "simplify" either call away.
- Hence its PATH loop **strips then prepends** — skipping dirs already present can fix absence
  but never ordering. The strip is a `while` loop because one `${p//:d:/:}` pass misses *adjacent*
  duplicates, which DevEnv's init really does create.
- `~/.zshenv` must stay silent and cheap: it runs for every zsh including non-interactive ones,
  and stray stdout breaks `scp`/`sftp`.
- Bash gets nothing non-interactively (`bash -c` reads no startup file without `BASH_ENV`), and
  login bash reads the first of `~/.bash_profile`, `~/.bash_login`, `~/.profile`, so without the
  first two it never reaches `~/.bashrc` → `.bashrc.user` unless `~/.profile` sources it (README
  "Shell startup hook"). Both are known: the first is unfixed, the second is fixed per box, not by
  the installer.
- Stray `~/*.old` / `*.bak` files mislabel their source (`.zshrc.user.old` held `~/.zshrc`).
  Always `cmp` against the live file before assuming a backup holds your config.

**DevEnv Linux only.** `~/.zshrc`, `~/.zprofile`, `~/.bashrc`, `~/.bash_profile` are
DevEnv-managed and **rewritten on every login shell** (verified: mtimes move after one
`zsh -lic`). Editing them is pointless and they can never be stowed — hook in via the `.user`
files.
- DevEnv's `~/.zprofile` sources `~/.zshrc` only in non-interactive shells, so `~/.zshrc` runs
  once in every login shell (measured 2026-10-27, `zsh -o sourcetrace` under `-lic` and `-lc`).
  Older images sourced it unconditionally, running it **twice** in interactive login shells —
  tmux panes are login shells (`default-command ''` → argv `-zsh`). `~/.zshrc` still re-sources
  `/etc/zshrc`, so that one runs twice in interactive shells. Neither is fixable from our side.
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
- `vim.lsp.config()` list fields replace the upstream default wholesale (measured on 0.12.6:
  clangd resolves to exactly our 5 `root_markers`, not lspconfig's 7), so a plain `root_markers`
  list is safe.
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
  `get-clipboard` at its default `buffer` (3.7b and 3.8); `request`/`both` returns nothing. A
  remote app cannot query the Mac clipboard from here.
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
Floats are unused by choice. The tmux defaults that create them stay bound — avoid them:
`prefix *` → `new-pane` (3.7b and 3.8) and, on 3.8 only, `prefix BTab` → `new-pane -E …;
move-pane -P bottom-centre`. 3.8's matching `prefix Tab` default is overridden by extrakto
(`@extrakto_key` defaults to `tab`), so in the resolved config it opens extrakto (measured with
`-f /dev/null` and `-f tmux/.tmux.conf`). The remaining blocker is upstream, so the fix is a tmux
upgrade, not config here — re-check it before building on floats.
- **Fixed in 3.8: `@continuum-restore`.** On 3.7 a float's `<...>` segment in `window_layout` made
  `select-layout` reject the string tmux just emitted, failing the whole window's restore. 3.8
  emits JSON layouts that round-trip with floats and still accepts 3.7 strings — but 3.7b rejects
  a 3.8-saved layout, so resurrect files do not survive a downgrade.
- **Still blocked on 3.8: outside our vi navigation model.** `select-pane -L/-D/-U/-R` (what
  `C-h/j/k/l` run) walks tiled geometry, which a float is not part of. Measured: directional keys
  never reach the float, and from inside it all four no-op — for a shell (smart-splits'
  `@pane-is-vim` false) and for nvim (guard true, nvim asks tmux, still no-op). Only `prefix o`
  and `prefix ;` escape, so enabling would mean binding one of those or a
  `#{pane_floating_flag}`-aware nav binding.
- 3.8 lifted the lesser limits: `resize-pane`/`move-pane`, swap and float↔tile (`prefix @`) work.
- Copy mode, vi motions and selection all work *inside* a float — the problem is only focus.
- `prefix Enter` (`display-popup -E`) already covers throwaway scratch shells with none of this:
  it is a client overlay, not a pane (never in `list-panes`), so resurrect never sees it.

## Conventions
- Shared shell logic lives in `shell/.config/shell/`, sourced by both bash and zsh — put
  cross-shell code there, never duplicated per shell.
- `claude/.claude/settings.json` is tracked but copied, not stowed: Claude Code rewrites
  `~/.claude/settings.json` at runtime (`/model`, `/effort`, plugin toggles, `rtk init -g`) and
  writes through a symlink (measured), which would dirty the repo. The installer copies the
  tracked file only when the live one is missing (or is a leftover symlink) and never overwrites
  it; sync repo changes by hand. There is no user-scope `settings.local.json`:
  `~/.claude/settings.local.json` is not loaded (measured), only a project's
  `.claude/settings.local.json` is.
- `codex/` is stowed `--no-folding`: a folded `~/.codex` would land `auth.json` in the repo.
  `~/.codex/config.toml` stays untracked (codex rewrites it); settings for Claude-driven runs live
  only in `codex/.codex/claude.config.toml` (`codex exec -p claude`), used by the `codex` agent.
- `rtk/` (Linux only) tracks `config.toml` alone, `--no-folding`: rtk keeps `llm-proxy/`, `plugins/`
  and pipeline files in `~/.config/rtk`. Unknown keys are ignored, and a present `[tracking]`,
  `[display]`, `[filters]` or `[limits]` section missing any key (or `[telemetry]` without
  `enabled`) voids the whole file — the hook silently falls back to defaults; only `rtk config`
  prints `missing field` — so `[limits]` keeps its dead keys. `filters.toml` stays untracked: it
  is trust-gated by sha, so every pull would disable it until `rtk trust`. `rtk telemetry …` /
  `rtk config --create` rewrite the file wholesale. Verify with `rtk config` and
  `rtk rewrite '<cmd>'` (empty = excluded) under a scratch `XDG_CONFIG_HOME` holding
  `rtk/config.toml`.
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
