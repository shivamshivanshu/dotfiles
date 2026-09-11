_shell_init_cache="${XDG_CONFIG_HOME:-$HOME/.config}/shell/init-cache.sh"
[[ -r "$_shell_init_cache" ]] && source "$_shell_init_cache"
unset _shell_init_cache

#### fzf
_cache_init fzf "$HOME/.cache/fzf-init.bash" fzf --bash

_source_shell_modules fzf alias worktree

#### zoxide
_cache_init zoxide "$HOME/.cache/zoxide-init.bash" zoxide init bash

PROMPT_COMMAND='printf "\e[1 q"'"${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

#### direnv
_cache_init direnv "$HOME/.cache/direnv-init.bash" direnv hook bash
