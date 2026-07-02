#### Prompt
autoload -Uz vcs_info
precmd() { vcs_info; printf '\e[1 q' }
zstyle ':vcs_info:git:*' formats ' %F{blue}git:(%F{red}%b%F{blue})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}git:(%F{red}%b|%a%F{blue})%f'
setopt PROMPT_SUBST
PROMPT='%(?.%B%F{green}➜%f%b .%B%F{red}➜%f%b ) %F{cyan}%c%f${vcs_info_msg_0_} '

#### fzf
# Cache the generated init script; regenerate only when the fzf binary is newer
# than the cache, so we don't shell out to `fzf --zsh` on every startup.
if command -v fzf &>/dev/null; then
  _fzf_cache="$HOME/.cache/fzf-init.zsh"
  if [[ ! -f "$_fzf_cache" ]] || [[ "$(command -v fzf)" -nt "$_fzf_cache" ]]; then
    mkdir -p "$HOME/.cache"
    fzf --zsh > "$_fzf_cache"
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
  _zoxide_cache="$HOME/.cache/zoxide-init.zsh"
  if [[ ! -f "$_zoxide_cache" ]] || [[ "$(command -v zoxide)" -nt "$_zoxide_cache" ]]; then
    mkdir -p "$HOME/.cache"
    zoxide init zsh > "$_zoxide_cache"
  fi
  source "$_zoxide_cache"
  unset _zoxide_cache
fi

#### autosuggestions
if [[ -f "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

#### atuin
# Loaded last so its Ctrl+R binding wins over fzf-history-widget.
# Cache the init script, same trick as fzf/zoxide above.
if command -v atuin &>/dev/null; then
  _atuin_cache="$HOME/.cache/atuin-init.zsh"
  if [[ ! -f "$_atuin_cache" ]] || [[ "$(command -v atuin)" -nt "$_atuin_cache" ]]; then
    mkdir -p "$HOME/.cache"
    atuin init zsh --disable-up-arrow > "$_atuin_cache"
  fi
  source "$_atuin_cache"
  unset _atuin_cache
fi

#### syntax highlighting
# Must be sourced last so it wraps all previously-defined widgets.
if [[ -f "${HOME}/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "${HOME}/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
