#### Tool init-script cache
# Shared by bash and zsh; symlinked to ~/.config/shell/init-cache.sh via `stow shell`.
# Cache a tool's generated shell-init script and regenerate it only when the binary
# is newer than the cache, so startup doesn't shell out to the tool every time.
_cache_init() {  # $1=tool  $2=cache-file  then the init command + args
  local bin; bin="$(command -v "$1")" || return
  local cache="$2"; shift 2
  if [[ ! -f "$cache" || "$bin" -nt "$cache" ]]; then
    mkdir -p "${cache%/*}"
    # Write via temp + mv so a failed generator can't poison the cache
    local tmp="$cache.tmp.$$"
    if "$@" > "$tmp"; then
      mv "$tmp" "$cache"
    else
      rm -f "$tmp"
      # Fall back to the stale cache rather than losing the tool this session
      [[ -f "$cache" ]] && source "$cache"
      return 1
    fi
  fi
  source "$cache"
}
