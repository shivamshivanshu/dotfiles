#### Prompt
autoload -Uz vcs_info
autoload -Uz add-zsh-hook
_prompt_precmd() { vcs_info; printf '\e[1 q' }
add-zsh-hook precmd _prompt_precmd
zstyle ':vcs_info:git:*' formats ' %F{blue}git:(%F{red}%b%F{blue})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}git:(%F{red}%b|%a%F{blue})%f'
setopt PROMPT_SUBST
PROMPT='%(?.%B%F{green}➜%f%b .%B%F{red}➜%f%b ) %F{cyan}%c%f${vcs_info_msg_0_} '

_shell_init_cache="${XDG_CONFIG_HOME:-$HOME/.config}/shell/init-cache.sh"
[[ -r "$_shell_init_cache" ]] && source "$_shell_init_cache"
unset _shell_init_cache

#### fzf
_cache_init fzf "$HOME/.cache/fzf-init.zsh" fzf --zsh

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
_cache_init zoxide "$HOME/.cache/zoxide-init.zsh" zoxide init zsh

#### autosuggestions
if [[ -f "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

#### atuin
# Loaded last so its Ctrl+R binding wins over fzf-history-widget.
_cache_init atuin "$HOME/.cache/atuin-init.zsh" atuin init zsh --disable-up-arrow
