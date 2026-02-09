command -v fzf &>/dev/null && eval "$(fzf --bash)"

export FZF_DEFAULT_OPTS=" \
  --color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374 \
  --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934 \
  --color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934"
