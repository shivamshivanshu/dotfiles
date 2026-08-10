# Sourced again from .zshrc.user so interactive PATH order survives macOS path_helper.
_shell_env="${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"
[[ -r "$_shell_env" ]] && source "$_shell_env"
unset _shell_env
