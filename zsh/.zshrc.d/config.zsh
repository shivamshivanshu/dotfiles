# Prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{blue}git:(%F{red}%b%F{blue})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}git:(%F{red}%b|%a%F{blue})%f'
setopt PROMPT_SUBST
PROMPT='%(?.%B%F{green}➜%f%b .%B%F{red}➜%f%b ) %F{cyan}%c%f${vcs_info_msg_0_} '

# fzf — cache the generated init script and only regenerate when the fzf binary
# is newer than the cache, so we don't shell out to `fzf --zsh` on every startup.
if command -v fzf &>/dev/null; then
  _fzf_cache="$HOME/.cache/fzf-init.zsh"
  if [[ ! -f "$_fzf_cache" ]] || [[ "$(command -v fzf)" -nt "$_fzf_cache" ]]; then
    mkdir -p "$HOME/.cache"
    fzf --zsh > "$_fzf_cache"
  fi
  source "$_fzf_cache"
  unset _fzf_cache
fi
# Use fd to walk files/dirs (honours .gitignore, includes dotfiles, skips .git)
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --strip-cwd-prefix --exclude .git'
fi

# Preview picks eza (dirs) or bat (files); falls back to echo so Ctrl-R stays readable
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374 \
  --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934 \
  --color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934 \
  --preview '([ -d {} ] && eza --tree --level=2 --icons --color=always {} || bat --style=numbers --color=always --line-range :500 {}) 2>/dev/null || echo {}' \
  --preview-window 'right,60%,border-left'"

# zoxide
if command -v zoxide &>/dev/null; then
  _zoxide_cache="$HOME/.cache/zoxide-init.zsh"
  if [[ ! -f "$_zoxide_cache" ]] || [[ "$(command -v zoxide)" -nt "$_zoxide_cache" ]]; then
    mkdir -p "$HOME/.cache"
    zoxide init zsh > "$_zoxide_cache"
  fi
  source "$_zoxide_cache"
  unset _zoxide_cache
fi

# autosuggestions
if [[ -f "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# atuin (last so its Ctrl+R binding wins over fzf-history-widget)
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi
