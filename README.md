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

| Keys | Mode | Action |
|------|------|--------|
| `gy` | n, x | Yank to register `a` |
| `gp` | n, x | Paste from register `a` |
| `<leader>y` | n, v | Yank to system clipboard |
| `<leader>Y` | n | Yank line to system clipboard |
| `<leader>p` | x | Paste without overwriting register |

### Windows / Navigation

| Keys | Action |
|------|--------|
| `<leader>wh/j/k/l` | Move to split |
| `<C-h/j/k/l>` | Tmux-aware navigation |
| `<C-\>` | Tmux previous pane |

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
| `<leader>s.` | Recent files |
| `<leader>sn` | Neovim config files |
| `<leader>so` | Files (Oil dir aware) |
| `<leader>st` | Grep (Oil dir aware) |
| `<leader>sW` | Grep word (Oil dir aware) |
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
| `]c` / `[c` | Next / prev hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gh` | Toggle line blame |
| `<leader>gu` | Reset hunk |

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

### Flash

| Keys | Mode | Action |
|------|------|--------|
| `s` | n, x, o | Flash jump |
| `S` | n, x, o | Flash treesitter select |
| `r` | o | Remote flash |

### Undotree

| Keys | Action |
|------|--------|
| `<leader>u` | Toggle undo tree |

### Comments

| Keys | Action |
|------|--------|
| `gc` | Toggle linewise comment |
| `gb` | Toggle blockwise comment |

### Search & Replace (Spectre)

| Keys | Action |
|------|--------|
| `<leader>h` | Open Spectre |
| `<leader>hw` | Replace word / selection |
| `<leader>hf` | Replace in current file |
| `<leader>hc` | Replace current line (inside Spectre) |
| `<leader>ha` | Replace all (inside Spectre) |

### Completion (nvim-cmp)

| Keys | Action |
|------|--------|
| `<C-Space>` | Trigger completion |
| `<CR>` | Confirm selection |
| `<C-n>` | Next item / snippet jump |
| `<C-p>` | Prev item / snippet jump |

### Markdown (`<leader>m`)

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
| `<leader>ml` | Add list item below |
| `<leader>mL` | Add list item above |
| `<leader>mc` | Toggle checkbox |
| `<leader>mp` | Toggle browser preview |
| `<leader>mr` | Toggle in-buffer rendering |

### Epoch Converter

| Keys | Mode | Action |
|------|------|--------|
| `<leader>ec` | x | Convert epoch/date |
| `<leader>ee` | x | Convert and copy |
| `<leader>ey` | n | Copy last result |
| `:Epoch <ts>` | cmd | Convert timestamp |
| `:EpochSetTimezone <h>` | cmd | Set timezone offset |
| `:EpochSetGranularity <unit>` | cmd | Set unit (ns/us/ms/s) |
