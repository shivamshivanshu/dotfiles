if command -v zoxide &>/dev/null; then
  _zoxide_cache="$HOME/.cache/zoxide-init.zsh"
  if [[ ! -f "$_zoxide_cache" ]] || [[ "$(command -v zoxide)" -nt "$_zoxide_cache" ]]; then
    mkdir -p "$HOME/.cache"
    zoxide init zsh > "$_zoxide_cache"
  fi
  source "$_zoxide_cache"
  unset _zoxide_cache
fi
