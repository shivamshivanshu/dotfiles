#### fzf x fd
# Use fd to walk files/dirs (honours .gitignore, includes dotfiles, skips .git).
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --strip-cwd-prefix --exclude .git'
fi

#### fzf appearance + preview
# Preview picks eza (dirs) or bat (files); falls back to echo so Ctrl-R stays readable.
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374 \
  --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934 \
  --color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934 \
  --preview '([ -d {} ] && eza --tree --level=2 --icons --color=always {} || bat --style=numbers --color=always --line-range :500 {}) 2>/dev/null || echo {}' \
  --preview-window 'right,60%,border-left'"

#### fzf x tmux
# Ctrl-T/Ctrl-R/Alt-C in a popup; fzf only consults this inside tmux
export FZF_TMUX_OPTS='-p 80%,80%'

#### less
if command -v bat &>/dev/null; then
  export LESSOPEN='| bat --color=always --style=plain --paging=never %s'
  export LESS='-R'
fi
