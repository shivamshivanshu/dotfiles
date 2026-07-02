#### fzf
# Cache the generated init script; regenerate only when the fzf binary is newer
# than the cache, so we don't shell out to `fzf --bash` on every startup.
if command -v fzf &>/dev/null; then
  _fzf_cache="$HOME/.cache/fzf-init.bash"
  if [[ ! -f "$_fzf_cache" ]] || [[ "$(command -v fzf)" -nt "$_fzf_cache" ]]; then
    mkdir -p "$HOME/.cache"
    fzf --bash > "$_fzf_cache"
  fi
  source "$_fzf_cache"
  unset _fzf_cache
fi

_shell_fzf="${XDG_CONFIG_HOME:-$HOME/.config}/shell/fzf.sh"
[[ -r "$_shell_fzf" ]] && source "$_shell_fzf"
unset _shell_fzf

#### zoxide
# Same init-script caching trick as fzf above.
if command -v zoxide &>/dev/null; then
  _zoxide_cache="$HOME/.cache/zoxide-init.bash"
  if [[ ! -f "$_zoxide_cache" ]] || [[ "$(command -v zoxide)" -nt "$_zoxide_cache" ]]; then
    mkdir -p "$HOME/.cache"
    zoxide init bash > "$_zoxide_cache"
  fi
  source "$_zoxide_cache"
  unset _zoxide_cache
fi

PROMPT_COMMAND='printf "\e[1 q"'"${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
