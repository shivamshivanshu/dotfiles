_shell_init_cache="${XDG_CONFIG_HOME:-$HOME/.config}/shell/init-cache.sh"
[[ -r "$_shell_init_cache" ]] && source "$_shell_init_cache"
unset _shell_init_cache

#### fzf
_cache_init fzf "$HOME/.cache/fzf-init.bash" fzf --bash

_shell_fzf="${XDG_CONFIG_HOME:-$HOME/.config}/shell/fzf.sh"
[[ -r "$_shell_fzf" ]] && source "$_shell_fzf"
unset _shell_fzf

_shell_alias="${XDG_CONFIG_HOME:-$HOME/.config}/shell/alias.sh"
[[ -r "$_shell_alias" ]] && source "$_shell_alias"
unset _shell_alias

_shell_worktree="${XDG_CONFIG_HOME:-$HOME/.config}/shell/worktree.sh"
[[ -r "$_shell_worktree" ]] && source "$_shell_worktree"
unset _shell_worktree

#### zoxide
_cache_init zoxide "$HOME/.cache/zoxide-init.bash" zoxide init bash

PROMPT_COMMAND='printf "\e[1 q"'"${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
