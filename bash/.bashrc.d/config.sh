# fzf
if command -v fzf &>/dev/null; then
  _fzf_cache="$HOME/.cache/fzf-init.bash"
  if [[ ! -f "$_fzf_cache" ]] || [[ "$(command -v fzf)" -nt "$_fzf_cache" ]]; then
    mkdir -p "$HOME/.cache"
    fzf --bash > "$_fzf_cache"
  fi
  source "$_fzf_cache"
  unset _fzf_cache
fi
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374 \
  --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934 \
  --color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934"

# zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"
