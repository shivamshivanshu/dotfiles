# Dotfiles ~ Shivam

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each package
directory mirrors where its files land in `$HOME`. `STOW_PACKAGES` in
`install_dotfiles.sh` lists the cross-platform packages, and
`register_platform_packages()` adds the platform-only ones marked in Layout
(`dnf` keys on `/etc/fedora-release`, so EL/Rocky do not get it). `tests/` and
`.githooks/` are not packages.

## Layout

```
nvim/.config/nvim/...            → ~/.config/nvim/...
alacritty/.config/alacritty/...  → ~/.config/alacritty/...
wezterm/.config/wezterm/...      → ~/.config/wezterm/...
tmux/.tmux.conf                  → ~/.tmux.conf
git/.gitconfig                   → ~/.gitconfig
dnf/.config/dnf/dnf.conf         → ~/.config/dnf/dnf.conf  (Fedora only)
aerospace/.config/aerospace/     → ~/.config/aerospace/  (macOS only, i3-style tiling WM)
bash/.bashrc.user                → ~/.bashrc.user
bash/.bashrc.d/                  → ~/.bashrc.d/
zsh/.zshenv                      → ~/.zshenv
zsh/.zshrc.user                  → ~/.zshrc.user
zsh/.zshrc.d/                    → ~/.zshrc.d/
shell/.config/shell/             → ~/.config/shell/
scripts/.local/bin/              → ~/.local/bin/  (cheatsheet.py — keybind cheatsheet)
ssh/.ssh/config                  → ~/.ssh/config  (work/machine hosts: untracked ~/.ssh/config.local)
claude/.claude/CLAUDE.md         → ~/.claude/CLAUDE.md
claude/.claude/skills/           → ~/.claude/skills/
claude/.claude/agents/           → ~/.claude/agents/
claude/.claude/output-styles/    → ~/.claude/output-styles/
claude/.claude/commands/         → ~/.claude/commands/
claude/.claude/hooks/            → ~/.claude/hooks/
claude/.claude/keybindings.json  → ~/.claude/keybindings.json
claude/.claude/settings.json     ⇒ ~/.claude/settings.json (copied, not linked)
codex/.codex/claude.config.toml  → ~/.codex/claude.config.toml  (codex profile for Claude-driven runs)
rtk/.config/rtk/config.toml      → ~/.config/rtk/config.toml  (Linux only; macOS rtk reads Application Support)
```

`claude`, `codex`, `rtk` and `ssh` are stowed with `--no-folding`, so `~/.claude`,
`~/.codex`, `~/.config/rtk`, `~/.ssh` and every directory under them stay real (credentials,
sessions, keys) and each tracked file is linked individually.

`settings.json` is tracked, but Claude Code rewrites it at runtime, so `link`
copies it into place only when `~/.claude/settings.json` is missing (or is a
leftover symlink) and never overwrites it. Machine-local edits live in that
copy — Claude Code has no user-level `settings.local.json`. Sync repo changes
by hand, including when Claude Code ran before the first install:
`diff ~/.claude/settings.json claude/.claude/settings.json`.

## Cheatsheet

`cheatsheet` (an interactive-shell alias for `cheatsheet.py`) regenerates
`~/.cache/cheatsheet.html` from the live configs and prints its `file://` URL.
For a live server that runs until stopped (or reboot):

```bash
cheatsheet --serve --port 36969 >/dev/null 2>&1 & disown   # start, detached
lsof -i :36969                                             # what's on the port
kill $(lsof -ti :36969)                                    # stop; rerun start to restart
```

It binds `127.0.0.1`; from another machine, `ssh -L 36969:localhost:36969 <host>`.

## Install

Prerequisites: `git`; Homebrew on macOS (`auto` exits without it); `sudo` on
Linux. Claude Code and the Codex CLI are installed separately.

```bash
git clone https://github.com/shivamshivanshu/dotfiles.git ~/dotfiles   # any location works
cd ~/dotfiles

./install_dotfiles.sh auto     # or: auto brew|apt|dnf|pacman|yay (auto-detected if omitted)
./install_dotfiles.sh link     # link only, no package installs
./install_dotfiles.sh manual   # print the dependency manifest
./install_dotfiles.sh check    # verify the manifest's commands and minimum versions
```

- `auto` installs the manifest's system packages, bootstraps rustup when
  `cargo` is missing, installs the cargo and go tools into `~/.local`, runs
  everything `link` does, clones TPM (installing the tmux plugins) and
  zsh-autosuggestions, then runs `check`. System packages go first, so a
  failure there leaves nothing linked; fix it and rerun `auto`, which skips
  whatever is already installed.
- `link` creates `~/.config`, `~/.local/bin` (so Stow never folds them into
  the repo) and `~/.ssh/sockets` (with `~/.ssh`, mode 700), seeds
  `settings.json` (above), moves a divergent real `~/.ssh/config`,
  `~/.zshenv` or (Linux) `~/.config/rtk/config.toml` to `<name>.pre-stow`
  (an identical one is deleted), stows every
  package, and enables the git hooks. Any other pre-existing real target
  (e.g. a stock `~/.gitconfig`) aborts the whole run at that package —
  earlier packages stay linked; clear it (see
  [Managing symlinks manually](#managing-symlinks-manually)) and rerun.
- Without `auto`, install what `manual` lists (`check` verifies exactly that
  list), plus TPM (`prefix I` once cloned) and zsh-autosuggestions. Neither
  mode installs `python3` (the Claude hooks). Alacritty is unused (WezTerm is
  the terminal); only its config is linked.
- After a `.pre-stow` move, carry over what you still need: work hosts from
  `~/.ssh/config.pre-stow` go into `~/.ssh/config.local` (optional; the
  tracked `config` `Include`s it first), and review `~/.zshenv.pre-stow` and
  (Linux) `~/.config/rtk/config.toml.pre-stow`.

### Linux: nvim, tmux, stow, fzf, wezterm

`auto` stops at the first package still missing or too old after installing
it, and `check` enforces nvim ≥ 0.12.0 and tmux ≥ 3.7.0 (`MIN_NVIM_VERSION`,
`MIN_TMUX_VERSION`). Distro repos lag (EL9: neovim 0.8.0 (EPEL), tmux 3.2a
(3.5a on DevEnv); Ubuntu 24.04: neovim 0.9.5, tmux 3.4), so on those hosts
first:
- build nvim ([below](#build-from-source)) and tmux (repo-root `CLAUDE.md`,
  "tmux from source") into `~/.local`, whose `bin` precedes the system dirs
  on PATH (the installer prepends it too);
- EL9: enable EPEL for `stow` and `fzf` (`sudo dnf install epel-release` on
  Rocky/Alma);
- add WezTerm's own package repo
  ([wezterm.org/install/linux](https://wezterm.org/install/linux.html)) —
  `wezterm` is in the manifest on every OS, and the EL9 and Ubuntu repos lack
  it.

### Shell startup hook

The installer never edits `~/.zshrc` or `~/.bashrc`. On any machine whose rc
files do not already source the `.user` files (e.g. a new Mac or a personal
Linux box), add `source ~/.zshrc.user` to `~/.zshrc` and
`source ~/.bashrc.user` to `~/.bashrc`. Login bash (macOS terminals, tmux
panes) reads the first of `~/.bash_profile`, `~/.bash_login`, `~/.profile`
instead, so make that one source `~/.bashrc`.
DevEnv (managed work boxes) rc files already source both and are rewritten
on every login, so do not edit them there.

### Updating

After `git pull`, rerun `./install_dotfiles.sh link`, then `check`. If
`check` reports something missing or too old, rerun `auto` (a too-old nvim or
tmux on EL9/Ubuntu needs a source build instead, as in the Linux
subsection). If the pull touched `claude/.claude/settings.json`, `diff` it
against the live copy (above); if tmux.conf gained a `@plugin`, press
`prefix I` (or rerun `auto`). Edits to already-linked files are live without
any of this.

## Development

`auto` and `link` set `core.hooksPath` to `.githooks` (undo:
`git config --unset core.hooksPath`). Its pre-commit hook runs `stylua` on
staged `*.lua` files and `shfmt -w` on staged `*.sh`, `*.bash`, `*.zsh`,
`.bashrc*`, `.zshrc*` and `.githooks/*` files (so not `zsh/.zshenv`). It
formats the working-tree copy, so a partially staged file gets its unstaged
hunks formatted too — re-stage with `git add -p`. If it reformats anything it
aborts the commit: review, `git add`, commit again. A missing `stylua` or
`shfmt` fails every commit that touches those files.

Installer regression test (stubs brew/cargo/go/sudo):
`tests/install_functions_test.sh`.

## Managing symlinks manually

Run from the repo root, and only for plain packages (nvim, tmux, git,
wezterm, …). `claude`, `codex`, `rtk`, `ssh` and `zsh` need `link`'s flags or
pre-stow handling — a bare `stow claude` would link `settings.json`. Run
`link` once first, or `mkdir -p ~/.config ~/.local/bin`, so Stow does not fold
those directories into the repo.

```bash
stow -t ~ nvim tmux git                # install
stow -Rt ~ nvim                        # restow (after adding or deleting files)
stow -Dt ~ nvim                        # uninstall
stow -nvt ~ nvim                       # dry-run + verbose
```

If Stow complains that a target already exists as a real file, either back it
up and remove it, or use `stow --adopt` to absorb it into the repo. `--adopt`
overwrites the tracked file with the machine's copy: check `git diff`, and
`git checkout -- <file>` to keep the repo version.

## Claude Code

Personal, project-agnostic skills, auto-discovered from `~/.claude/skills/`.
Keep these **free of work-internal names** — nothing internal (hostnames,
systems, ticket prefixes) goes here.

`~/.claude/CLAUDE.md` imports `working-style` so it is always loaded.

| Skill | Category | Triggers on |
|-------|----------|-------------|
| `working-style` | preferences | start of any task — how work should be done |
| `autonomous-mode` | preferences | "autonomous mode" / "kick off autonomous" — unattended run of an approved plan |
| `git` | preferences | commit / amend / rebase / worktree / review |
| `rtk` | preferences | rtk proxy — token savings, gain / discover / bypass |
| `codebase-recon` | preferences | understand / trace unfamiliar code before changing |
| `cpp` | insights | writing / reviewing C++ |
| `cpp-build` | insights | building / testing / debugging C++ |
| `bazel` | insights | bazel in worktrees — user.bazelrc, disk-cache seeding, output-base cleanup |
| `python` | insights | writing / testing Python |
| `perf-investigation` | insights | latency / throughput / CPU profiling |
| `concurrency` | insights | multithread / lock-free / memory ordering |
| `delegation` | meta | before spawning any subagent, teammate, codex leg or workflow |
| `agent-team` | meta | sizeable, separable implementation — dependency-tree delegation across subagents |
| `fan-n` | meta | one sample isn't trustworthy — fan N agents over the same prompt, fan-in ranks consensus |
| `stochastic-consensus` | meta | open problem exploration — independent solutions ranked, then cross-examined in debate rounds |
| `design-doc` | meta | writing a design doc / RFC / ADR — structure and tradeoff discipline |
| `doc-reviewer` | meta | plan / design doc written — multi-agent review, Q&A loop, audit |
| `session-insight` | meta | `/wrap` insight step, or an explicit retro request |
| `teacher` | meta | `/wrap` teacher step, or an explicit ask to learn from finished work |
| `handoff` | meta | `/handoff [name]` or `/wrap` with unfinished work — save a resumable context handoff |

**Agents** (`agents/`): `simple-implementer` (simple well-specified subtasks,
inherits the session model), `verifier` (build / test / regression, reports
PASS/FAIL with evidence), and `codex` — a haiku bridge to the OpenAI Codex CLI
for independent reads (reviews, exploration, debugging, second opinions) and
the other-model leg of review and audit fan-outs; not for edits. It runs
`codex exec -p claude`, which loads the read-only profile from the `codex`
package. Needs the Codex CLI and `codex login`, and spends OpenAI quota.

**Output styles** (`output-styles/`, named by their `name:` field):
`Teaching` — example-led explanations with mechanism traces, for deep-dives
rather than routine work. `Recall` (`recall.md`) — active recall: Claude
builds the scaffolding and hands over the deciding code, for upskilling rather
than shipping. The seeded `settings.json` makes `Recall` the default; switch
with `/output-style Recall` (not `learning`, which is Claude Code's built-in
Learning style).

**Commands** (`commands/`): `/wrap` closes a session (optional handoff, then
session-insight and teacher); `/wip` summarises uncommitted work and writes a
crash-safe checkpoint.

**Hooks** (`hooks/`, wired in `settings.json`): `session_start.py` provisions
the dated scratchpad and surfaces handoffs, `/wip` checkpoints and output
styles; `notify.py` keeps a per-window tmux state glyph and raises a WezTerm
toast when Claude waits or finishes.

## Shell

zsh and bash both source modular config from `.{z,b}shrc.d/`. Order-dependent
setup (prompt, fzf, zoxide, direnv, autosuggestions, atuin) lives in a single
`config.{zsh,sh}`; history options stay per shell. Cross-shell code (aliases,
fzf helpers, worktree helpers) lives in `shell/.config/shell/`, sourced by
both.

### Tools

All installed by `auto`.

| Tool | Purpose | zsh | bash |
|------|---------|-----|------|
| [atuin](https://github.com/atuinsh/atuin) | SQLite-backed history with fuzzy search | ✓ | — |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy file / cd picker | ✓ | ✓ |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` (`z <pattern>`, `zi` for picker) | ✓ | ✓ |
| [direnv](https://direnv.net/) | Load/unload approved project environments | ✓ | ✓ |
| zsh-autosuggestions | Inline command suggestions | ✓ | — |

### Project environments

Add an `.envrc` to a project and run `direnv allow` to approve it. Keep
secrets in an ignored file such as `.env.local`, then load it from `.envrc`
with `dotenv_if_exists .env.local`.

### Git worktrees

`gwt [-c] <name>` opens branch `<name>` (local, else remote, else new from
`HEAD`) in a worktree under `$LOCAL_WORKTREE_ROOT/<repo>/` (default
`~/worktree`) and `cd`s there; `-c` creates it fresh off `origin/main`. `gwts`
fzf-picks a worktree (the current repo's, if it has any) and `cd`s to it;
`gwtrm` fzf-picks one of the current repo's worktrees and removes it.

### Keybinds

zsh runs in vi mode (`bindkey -v`).

| Keys | zsh | bash |
|------|-----|------|
| `Ctrl+R` | atuin history search | fzf history search |
| `Ctrl+T` | fzf file picker | fzf file picker |
| `Alt+C` | fzf `cd` to subdir | fzf `cd` to subdir |
| `Ctrl+O` | edit the command line in `$EDITOR` | — |
| `Ctrl+P` | edit the last command in `$EDITOR`; runs it only if changed | — |
| `→` | accept inline autosuggestion | — |
| `↑` | classic line recall (atuin's up-arrow is disabled) | — |

### Refresh atuin's local history

```bash
atuin import zsh    # one-time import of existing zsh history
atuin sync          # only if you've registered for sync (off by default)
```

## NVIM

### Build from source

Needed wherever the distro nvim is below 0.12.0 (EL9 ships 0.8.0, Ubuntu
24.04 0.9.5). Build deps:
cmake, gettext and a C compiler (upstream `BUILD.md` lists the rest).

```bash
git clone --depth 1 --branch v0.12.6 https://github.com/neovim/neovim ~/src/neovim   # any tag >= v0.12.0
cd ~/src/neovim
make distclean   # only when rebuilding an existing tree
make CMAKE_BUILD_TYPE=Release \
     CMAKE_INSTALL_PREFIX="$HOME/.local" \
     CMAKE_EXTRA_FLAGS="-DUSE_BUNDLED=ON"
make install
nvim --version | head -1
```

### Keybinds

Leader: `Space`; localleader: `\`. `<leader>sk` searches the live keymaps.

#### General

| Keys | Action |
|------|--------|
| `<Esc>` | Clear search highlight |
| `<leader>t` | Open terminal |
| `<Esc><Esc>` | Exit terminal mode |
| `<leader>cp` | Copy absolute path |
| `<leader>cr` | Copy relative path |
| `<leader>f` | Format (conform/LSP; n and x) |
| `<C-BS>` / `<C-h>` | Delete previous word (insert and command line) |
| `-` | Open parent directory (Oil) |
| `<C-x>` | Oil: open entry in a horizontal split (`<C-h>` is nav) |
| `:Undotree` | Toggle undo tree |
| `<C-d>` / `<C-u>` | Half-page down / up, recentred |

Commands: `:TrimTrailspace` (trailing whitespace and blank lines),
`:ToggleHipatterns` (TODO/FIXME/hex highlighting), `:ToggleIndentScope`,
`:GoToContext [n]` (jump to the enclosing context line, `n` levels up),
`:SessionTrack` / `:SessionUntrack` (keep a `Session.vim` that
tmux-resurrect restores), `:ToggleUi2` (experimental message/cmdline UI),
`:Calendar`, `:Games` (needs a games.nvim server and password; see
`games.lua`).

#### Yank / Paste

`y`/`p` use the system clipboard directly (`clipboard=unnamedplus`).

| Keys | Mode | Action |
|------|------|--------|
| `<leader>p` | x | Paste without overwriting register |
| `<leader>cb` | n | Copy entire buffer to clipboard |

#### Windows / Navigation

| Keys | Action |
|------|--------|
| `<C-h/j/k/l>` | Move across nvim splits and tmux panes (smart-splits, loaded eagerly — see repo-root `CLAUDE.md`) |
| `<C-\>` | Tmux previous pane |
| `<A-arrows>` | Resize split |

#### Buffers

| Keys | Action |
|------|--------|
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |
| `<leader>bd` | Delete buffer (keep window layout) |

Commands: `:BufCloseOthers`, `:BufCloseLeft`, `:BufCloseRight` (relative to the
tabline).

#### Telescope (`<leader>s`)

| Keys | Action |
|------|--------|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Grep word under cursor |
| `<leader>sd` | Diagnostics |
| `<leader>sh` | Help tags |
| `<leader>sk` | Keymaps |
| `<leader>ss` | LSP symbols |
| `<leader>sr` | Resume last search |
| `<leader>sR` | Pick from picker history (multiple previous searches) |
| `<leader>s.` | Recent files |
| `<leader>sn` | Neovim config files |
| `<leader>so` | Files in current dir (Oil dir, file's dir, or cwd) |
| `<leader>st` | Grep in current dir (Oil dir, file's dir, or cwd) |
| `<leader>sW` | Grep word in current dir |
| `<leader>s/` | Grep in open files |
| `<leader>sa` | Search actions (registered command palette) |
| `<leader>/` | Fuzzy search current buffer |
| `<leader><leader>` | Find buffers |
| `<C-r>` | Inside a picker: refresh results, keeping the prompt |

#### LSP

| Keys | Action |
|------|--------|
| `gd` | Go to definition |
| `K` | Hover info |
| `gi` | Go to implementation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `[d` / `]d` | Prev / next diagnostic |

Commands: `:ToggleDiagnostics`, `:ToggleDiagnosticVirtualText`,
`:ToggleInlayHints`, `:DiagnosticsToQuickfix`, `:LspLog`.

#### Git Hunks (Gitsigns)

| Keys | Action |
|------|--------|
| `]c` / `[c` | Next / prev hunk (native jump in diff windows) |
| `<leader>gs` | Stage hunk (repeat to unstage) |
| `<leader>gp` | Preview hunk |
| `<leader>gu` | Reset hunk |

Commands: `:ToggleGitBlame` (inline blame for current line), `:CopyCommitHash` (hash of current line).

#### Treesitter

| Keys | Mode | Action |
|------|------|--------|
| `af` / `if` | x, o | Outer / inner function |
| `ac` / `ic` | x, o | Outer / inner class |
| `aa` / `ia` | x, o | Outer / inner parameter |
| `]m` / `[m` | n, x, o | Next / prev function start |
| `]M` / `[M` | n, x, o | Next / prev function end |
| `]]` / `[[` | n, x, o | Next / prev class start |
| `][` / `[]` | n, x, o | Next / prev class end |
| `]a` / `[a` | n, x, o | Next / prev parameter |
| `<leader>a` / `<leader>A` | n | Swap with next / previous parameter |
| `]n` / `[n` | x | Select next / previous node (nvim builtin) |
| `]N` / `[N` | x | Select next / previous sibling node (nvim builtin) |

nvim's builtin `an` / `in` (parent / child node) are shadowed by mini.ai's
`an` / `in` below.

#### Text Objects (mini.ai, mini.indentscope)

| Keys | Mode | Action |
|------|------|--------|
| `a{id}` / `i{id}` | x, o | Around / inside: `b` bracket, `q` quote, `t` tag, `?` prompt, any punctuation (`f`, `c`, `a` stay treesitter's) |
| `an{id}` / `in{id}` | x, o | Around / inside the next one |
| `al{id}` / `il{id}` | x, o | Around / inside the last one |
| `g[` / `g]` | n, x, o | Move to left / right edge of an "around" object |
| `ai` / `ii` | x, o | Indent scope with / without border |
| `[i` / `]i` | n, x, o | Indent scope top / bottom |

#### Surround

| Keys | Mode | Action |
|------|------|--------|
| `ys{motion}{char}` | n | Add surround |
| `yss{char}` | n | Surround current line |
| `ds{char}` | n | Delete surround |
| `cs{old}{new}` | n | Change surround |
| `S{char}` | x | Surround selection |

#### Comments (nvim builtin)

| Keys | Mode | Action |
|------|------|--------|
| `gc{motion}` | n | Toggle comment over motion |
| `gcc` | n | Toggle comment on current line |
| `gc` | x | Toggle comment on selection |

#### Search & Replace (grug-far)

VS Code-style search panel with separate fields for Search, Replacement, Files Filter
(supports globs like `src/**/*.cpp`, `!**/test/**`), and Flags (prefilled
`--ignore-case --hidden`).

Launch with `<leader>hh` or `:GrugFar`; `:GrugFarWord` prefills the word under
the cursor, `:GrugFarAst` searches structurally with ast-grep. Inside the panel:

| Keys | Action |
|------|--------|
| `\r` | Replace all |
| `\q` | Send results to quickfix |
| `\s` | Sync edits back to result locations |
| `\l` | Sync current line |
| `\f` | Refresh search |
| `\t` | Open search history |
| `<CR>` | Go to location / pick history entry |
| `q` | Close |

#### Diffview

`:DiffviewOpen`, `:DiffviewFileHistory`, `:DiffviewClose`. Inside a diffview tab:

| Keys | Where | Action |
|------|-------|--------|
| `\e` / `\b` | diff view, file panel, history panel | Focus / toggle the file panel |
| `\co` / `\ct` / `\cb` / `\ca` | diff view | Conflict hunk: choose ours / theirs / base / all |
| `\cO` / `\cT` / `\cB` / `\cA` | diff view, file panel | Whole file: choose ours / theirs / base / all |

#### Runner (C++ / Python)

| Command | Action |
|---------|--------|
| `:Run` | Build (C++) and run the current file |
| `:RunWithInput` | Run with `input.txt` as stdin, tee to `output.txt` |
| `:BuildRelease` / `:BuildWithDebugInfo` | Build the `.cpp` with `-O2` / `-O0 -g` |
| `:CleanBinary` | Remove the built binary |
| `:OpenInput` / `:OpenOutput` | Open `input.txt` / `output.txt` in a vsplit |

#### Completion (blink.cmp)

| Keys | Action |
|------|--------|
| `<C-Space>` | Trigger completion |
| `<CR>` | Confirm selection |
| `<C-n>` | Next item / snippet jump |
| `<C-p>` | Prev item / snippet jump |
| `<C-y>` | Accept (command-line completion) |

#### Markdown (markdown buffers only)

Emphasis keys: `b` bold, `i` italic, `c` code, `s` strikethrough.

| Keys | Mode | Action |
|------|------|--------|
| `gs{motion}{key}` | n | Toggle emphasis over motion (`gsiwb` = bold word) |
| `gs{key}` | x | Toggle emphasis on selection |
| `gss{key}` | n | Toggle emphasis on current line (`gssb` = bold line) |
| `gsd{key}` | n | Delete surrounding emphasis (`gsdb` = remove bold) |
| `gsc{old}{new}` | n | Change emphasis (`gscbi` = bold → italic) |
| `gl{motion}` / `gl` | n / x | Add link |
| `gx` | n | Follow link |
| `]]` / `[[` | n | Next / prev heading (overrides the class motion) |
| `]p` | n | Parent heading |
| `]h` | n | Current heading |
| `\l` / `\L` | n | Insert list item below / above |
| `\t` | n, x | Toggle task checkbox (x: whole range) |
| `\n` | n | Renumber ordered list |

Commands: `:MarkdownPreviewToggle` (browser preview; `:LivePreview start|close`
underneath), `:RenderMarkdown toggle` (in-buffer rendering).

#### Epoch Converter

| Command | Action |
|---------|--------|
| `:Epoch <ts>` / `:'<,'>Epoch` | Convert timestamp arg or visual range |
| `:Epoch` | Popup: type a timestamp/date, `<CR>` converts, `y` yanks result, `q` closes |
| `:'<,'>EpochCopy` / `:EpochCopy` | Convert range and copy / copy last result |
| `:EpochSetTimezone <hours>` | Set timezone offset in hours (default `5.5`) |
| `:EpochSetGranularity <unit>` | Set unit (ns/us/ms/s) |
