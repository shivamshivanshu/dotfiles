#### Tool init-script cache
# Shared by bash and zsh; symlinked to ~/.config/shell/init-cache.sh via `stow shell`.
# Cache a tool's generated shell-init script and regenerate it only when the binary
# is newer than the cache, so startup doesn't shell out to the tool every time.
_cache_init() {  # $1=tool  $2=cache-file  then the init command + args
  local bin; bin="$(command -v "$1")" || return
  local cache="$2"; shift 2
  if [[ ! -f "$cache" || "$bin" -nt "$cache" ]]; then
    mkdir -p "${cache%/*}"; "$@" > "$cache"
  fi
  source "$cache"
}
