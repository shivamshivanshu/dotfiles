## Dotfiles ~ Shivam

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory is a Stow package whose internal tree mirrors where files land in
`$HOME`.

### Layout

```
nvim/.config/nvim/...            → ~/.config/nvim/...
alacritty/.config/alacritty/...  → ~/.config/alacritty/...
wezterm/.config/wezterm/...      → ~/.config/wezterm/...
tmux/.tmux.conf                  → ~/.tmux.conf
git/.gitconfig                   → ~/.gitconfig
dnf/.config/dnf/dnf.conf         → ~/.config/dnf/dnf.conf  (Fedora only)
bash/.bashrc.user                → ~/.bashrc.user
bash/.bashrc.d/                  → ~/.bashrc.d/
zsh/.zshrc.user                  → ~/.zshrc.user
zsh/.zshrc.d/                    → ~/.zshrc.d/
shell/.config/shell/             → ~/.config/shell/
scripts/.local/bin/              → ~/.local/bin/  (cheatsheet.py — keybind cheatsheet)
claude/.claude/CLAUDE.md         → ~/.claude/CLAUDE.md
claude/.claude/skills/           → ~/.claude/skills/
claude/.claude/agents/           → ~/.claude/agents/
claude/.claude/output-styles/    → ~/.claude/output-styles/
claude/.claude/commands/         → ~/.claude/commands/
claude/.claude/hooks/            → ~/.claude/hooks/
claude/.claude/keybindings.json  → ~/.claude/keybindings.json
claude/.claude/settings.json     → ~/.claude/settings.json
```

`~/.claude` stays a real directory (credentials, sessions, caches); Stow folds
in only the tracked entries (`CLAUDE.md`, `skills/`, `agents/`, `output-styles/`,
`commands/`, `hooks/`, `keybindings.json`, `settings.json`) as symlinks.
`settings.json` **is** tracked — a universal settings file shared across
machines. Machine-local and work-internal overrides stay in `settings.local.json`
(untracked). Note Claude Code writes a real `settings.json` at runtime; the
installer removes any such file so the tracked one links.

### Cheatsheet

`cheatsheet` regenerates `~/.cache/cheatsheet.html` from the live configs and
prints its `file://` URL. For an always-on live server instead:

```bash
cheatsheet --serve --port 36969 >/dev/null 2>&1 & disown   # run detached
lsof -i :36969                                             # what's on the port
kill $(lsof -ti :36969) 2>/dev/null; cheatsheet --serve --port 36969 >/dev/null 2>&1 & disown   # restart
```

### Install

```bash
# Install packages (including stow itself) and symlink
./install_dotfiles.sh auto dnf         # or apt / pacman / yay / brew

# Only create symlinks (packages already installed)
./install_dotfiles.sh link

# Just list what would be installed
./install_dotfiles.sh manual
```

### Managing symlinks manually

```bash
stow -t ~ nvim tmux git                # install
stow -Rt ~ nvim                        # restow (after adding files)
stow -Dt ~ nvim                        # uninstall
stow -nvt ~ nvim                       # dry-run + verbose
```

If Stow complains that a target already exists as a real file, either back it
up and remove it, or use `stow --adopt` to absorb it into the repo (review the
diff afterwards).

## Claude Code

Personal, project-agnostic skills auto-discovered from `~/.claude/skills/`.
Category subfolders are discovered recursively; the whole tree is symlinked in
via Stow. Keep these **free of work-internal names** — nothing internal
(hostnames, systems, ticket prefixes) goes here.

`CLAUDE.md` imports `working-style` so it is always loaded.

| Skill | Category | Triggers on |
|-------|----------|-------------|
| `working-style` | preferences | start of any task — how work should be done |
| `git` | preferences | commit / amend / rebase / worktree / review |
| `rtk` | preferences | rtk proxy — token savings, gain / discover / proxy |
| `codebase-recon` | preferences | understand / trace unfamiliar code before changing |
| `cpp` | insights | writing / building / debugging C++ |
| `python` | insights | writing / testing Python |
| `perf-investigation` | insights | latency / throughput / CPU profiling |
| `concurrency` | insights | multithread / lock-free / memory ordering |
| `agent-team` | meta | sizeable, separable implementation — dependency-tree delegation across subagents |
| `fan-n` | meta | one sample isn't trustworthy — fan N agents over the same prompt, fan-in ranks consensus |
| `stochastic-consensus` | meta | open problem exploration — independent solutions ranked, then cross-examined in debate rounds |
| `design-doc` | meta | writing a design doc / RFC / ADR — structure and tradeoff discipline |
| `session-insight` | meta | "I'm done" — summarize + propose skill-repo edits |
| `teacher` | meta | task done — offer transferable concepts to learn (notes in `$HOME/claude_notes/`) |
| `handoff` | meta | `/handoff [name]` — save a resumable context handoff for a fresh instance |

**Agents** (`agents/`, also tracked): `simple-implementer` (Sonnet-pinned, for
simple well-specified subtasks) and `verifier` (build / test / regression,
reports PASS/FAIL with evidence).

**Output styles** (`output-styles/`): `terse` — lead with the answer, structured
and scannable. `teaching` — example-led explanations with mechanism traces, for
deep-dives rather than routine work. Activate with `/output-style <name>`.

**Also tracked**: `commands/` (custom slash commands), `hooks/` (event hook
scripts), `keybindings.json`, and `settings.json` (universal config; see above).

## Shell

zsh and bash both source modular config from `.{z,b}shrc.d/`. Order-dependent
setup (prompt, fzf, zoxide, autosuggestions, atuin) lives in a single
`config.{zsh,sh}`; aliases and history options stay separate.

### Tools

| Tool | Purpose | zsh | bash |
|------|---------|-----|------|
| [atuin](https://github.com/atuinsh/atuin) | SQLite-backed history with fuzzy search | ✓ | — |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy file / cd picker | ✓ | ✓ |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` (`z <pattern>`, `zi` for picker) | ✓ | ✓ |
| zsh-autosuggestions | Inline command suggestions | ✓ | — |

### Keybinds (zsh)

| Keys | Action |
|------|--------|
| `Ctrl+R` | atuin history search |
| `Ctrl+T` | fzf file picker |
| `Alt+C` | fzf `cd` to subdir |
| `→` / `Ctrl+F` | accept inline autosuggestion |
| `↑` | classic up-arrow line recall (atuin's up-arrow is disabled) |

### Keybinds (bash)

| Keys | Action |
|------|--------|
| `Ctrl+R` | fzf history search |
| `Ctrl+T` | fzf file picker |
| `Alt+C` | fzf `cd` to subdir |

### Refresh atuin's local history

```bash
atuin import zsh    # one-time import of existing zsh history
atuin sync          # only if you've registered for sync (off by default)
```

## NVIM

### Installation

To install neovim from source:
```bash
# clean any previous cache
make distclean

# Option 1: use the Makefile wrapper (simplest)
make CMAKE_BUILD_TYPE=Release \
     CMAKE_INSTALL_PREFIX="$HOME/.local" \
     CMAKE_EXTRA_FLAGS="-DUSE_BUNDLED=ON"

make install
```

### Split navigation

tmux owns `C-h/j/k/l` everywhere. smart-splits loads eagerly (`lazy = false`)
on purpose: it must set tmux's `@pane-is-vim` before the first nav key
arrives, so tmux knows whether to pass the key through — do not lazy-load it
to shave startup ms (~4 ms is the cost of correctness here).

### Keybinds Cheatsheet

Leader: `Space`

### General

| Keys | Action |
|------|--------|
| `<Esc>` | Clear search highlight |
| `<leader>t` | Open terminal |
| `<Esc><Esc>` | Exit terminal mode |
| `<leader>cp` | Copy absolute path |
| `<leader>cr` | Copy relative path |
| `<leader>f` | Format (conform/LSP) |

### Yank / Paste

`y`/`p` use the system clipboard directly (`clipboard=unnamedplus`).

| Keys | Mode | Action |
|------|------|--------|
| `<leader>p` | x | Paste without overwriting register |
| `<leader>cb` | n | Copy entire buffer to clipboard |

### Windows / Navigation

| Keys | Action |
|------|--------|
| `<C-h/j/k/l>` | Tmux-aware navigation (nvim splits included) |
| `<C-\>` | Tmux previous pane |
| `<A-arrows>` | Resize split |

### File Explorer (Oil)

| Keys | Action |
|------|--------|
| `-` | Open parent directory |

### Buffers

| Keys | Action |
|------|--------|
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |

### Telescope (`<leader>s`)

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
| `<leader>/` | Fuzzy search current buffer |
| `<leader><leader>` | Find buffers |

### LSP

| Keys | Action |
|------|--------|
| `gd` | Go to definition |
| `K` | Hover info |
| `gi` | Go to implementation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `[d` / `]d` | Prev / next diagnostic |

### Git Hunks (Gitsigns)

| Keys | Action |
|------|--------|
| `]c` / `[c` | Next / prev hunk (native jump in diff windows) |
| `<leader>gp` | Preview hunk |
| `<leader>gu` | Reset hunk |

Commands: `:Gitsigns toggle_current_line_blame`, `:CopyCommitHash` (hash of current line).

### Treesitter Text Objects

| Keys | Mode | Action |
|------|------|--------|
| `af` / `if` | x, o | Outer / inner function |
| `ac` / `ic` | x, o | Outer / inner class |
| `aa` / `ia` | x, o | Outer / inner parameter |

### Treesitter Movement

| Keys | Action |
|------|--------|
| `]m` / `[m` | Next / prev function start |
| `]M` / `[M` | Next / prev function end |
| `]]` / `[[` | Next / prev class start |
| `][` / `[]` | Next / prev class end |
| `]a` / `[a` | Next / prev parameter |

### Treesitter Swap

| Keys | Action |
|------|--------|
| `<leader>a` | Swap with next parameter |
| `<leader>A` | Swap with previous parameter |

### Treesitter Selection

| Keys | Action |
|------|--------|
| `gnn` | Init selection |
| `grn` | Expand to next node |
| `grc` | Expand to scope |
| `grm` | Shrink selection |

### Surround

| Keys | Mode | Action |
|------|------|--------|
| `ys{motion}{char}` | n | Add surround |
| `ds{char}` | n | Delete surround |
| `cs{old}{new}` | n | Change surround |
| `S{char}` | x | Surround selection |

### Undotree

`:UndotreeToggle`

### Comments

| Keys | Action |
|------|--------|
| `gc` | Toggle linewise comment |
| `gb` | Toggle blockwise comment |

### Search & Replace (grug-far)

VS Code-style search panel with separate fields for Search, Replacement, Files Filter
(supports globs like `cuttlefish/**/*.cpp`, `!**/test/**`), and Flags.

Launch with `:GrugFar`. Inside the panel:

| Keys | Action |
|------|--------|
| `<leader>ha` | Replace all |
| `<leader>hq` | Send results to quickfix |
| `<leader>hs` | Sync edits back to result locations |
| `<leader>hl` | Sync current line |
| `<leader>hr` | Refresh search |
| `<leader>ht` | Open search history |
| `q` | Close |

### Completion (nvim-cmp)

| Keys | Action |
|------|--------|
| `<C-Space>` | Trigger completion |
| `<CR>` | Confirm selection |
| `<C-n>` | Next item / snippet jump |
| `<C-p>` | Prev item / snippet jump |

### Markdown

| Keys | Action |
|------|--------|
| `gsb` | Toggle **bold** |
| `gsi` | Toggle *italic* |
| `gsc` | Toggle `code` |
| `gss` | Toggle ~~strikethrough~~ |
| `gsd` + key | Delete surrounding (`gsdb` = remove bold) |
| `gsc` + old + new | Change surrounding (`gscbi` = bold → italic) |
| `gl` | Add link |
| `gx` | Follow link |
| `]]` / `[[` | Next / prev heading |
| `]p` | Parent heading |
| `]h` | Current heading |

Commands: `:MDListItemBelow`, `:MDListItemAbove`, `:MDTaskToggle` (list/checkbox ops),
`:LivePreview start|close` (browser preview), `:RenderMarkdown toggle` (in-buffer rendering).

### Epoch Converter

| Command | Action |
|---------|--------|
| `:Epoch <ts>` / `:'<,'>Epoch` | Convert timestamp arg or visual range |
| `:'<,'>EpochCopy` / `:EpochCopy` | Convert range and copy / copy last result |
| `:EpochSetTimezone <h>` | Set timezone offset |
| `:EpochSetGranularity <unit>` | Set unit (ns/us/ms/s) |
