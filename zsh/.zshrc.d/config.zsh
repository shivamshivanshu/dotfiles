#### Prompt
autoload -Uz vcs_info
autoload -Uz add-zsh-hook
# Git is the only VCS in use; skip probing every other vcs_info backend per prompt.
zstyle ':vcs_info:*' enable git
zmodload zsh/datetime

_prompt_remote=""
if [[ -z ${TMUX:-} && (-n ${SSH_CONNECTION:-} || -n ${MOSH_CONNECTION:-}) ]]; then
	_prompt_remote="%F{yellow}[${HOST%%.*}]%f "
fi

_prompt_started_at=""
_prompt_duration=""
_prompt_preexec() { _prompt_started_at=$EPOCHREALTIME; }
_prompt_precmd() {
	local exit_status=$?
	vcs_info
	_prompt_duration=""
	if [[ -n $_prompt_started_at ]]; then
		local elapsed=$((EPOCHREALTIME - _prompt_started_at))
		if ((elapsed >= 2)); then
			_prompt_duration=$(printf ' %%F{yellow}%.1fs%%f' "$elapsed")
		fi
	fi
	_prompt_started_at=""
	printf '\e[1 q'
	return "$exit_status"
}
add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd _prompt_precmd
zstyle ':vcs_info:git:*' formats ' %F{blue}git:(%F{red}%b%F{blue})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}git:(%F{red}%b|%a%F{blue})%f'
setopt PROMPT_SUBST
PROMPT='%(?.%B%F{green}➜%f%b .%B%F{red}➜%f%b ) ${_prompt_remote}%F{cyan}%c%f${vcs_info_msg_0_}${_prompt_duration} '

_shell_init_cache="${XDG_CONFIG_HOME:-$HOME/.config}/shell/init-cache.sh"
[[ -r "$_shell_init_cache" ]] && source "$_shell_init_cache"
unset _shell_init_cache

#### fzf
_cache_init fzf "$HOME/.cache/fzf-init.zsh" fzf --zsh

_source_shell_modules fzf alias worktree

#### zoxide
_cache_init zoxide "$HOME/.cache/zoxide-init.zsh" zoxide init zsh

#### direnv
_cache_init direnv "$HOME/.cache/direnv-init.zsh" direnv hook zsh

#### autosuggestions
if [[ -f "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
	source "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
	ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

#### atuin
# Loaded last so its Ctrl+R binding wins over fzf-history-widget.
_cache_init atuin "$HOME/.cache/atuin-init.zsh" atuin init zsh --disable-up-arrow
