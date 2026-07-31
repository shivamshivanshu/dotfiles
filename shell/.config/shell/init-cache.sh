#### Tool init-script cache
# Cache a tool's generated shell-init script and regenerate it when the binary
# is newer than the cache or the init command line changed (stamped in line 1),
# so startup doesn't shell out to the tool every time.
_cache_init() { # $1=tool  $2=cache-file  then the init command + args
	local bin
	bin="$(command -v "$1")" || return
	local cache="$2"
	shift 2
	local stamp="# generated-by: $*"
	local first=""
	[[ -f "$cache" ]] && IFS= read -r first <"$cache"
	if [[ "$bin" -nt "$cache" || "$first" != "$stamp" ]]; then
		mkdir -p "${cache%/*}"
		# Write via temp + mv so a failed generator can't poison the cache
		local tmp="$cache.tmp.$$"
		if {
			echo "$stamp"
			"$@"
		} >"$tmp"; then
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
