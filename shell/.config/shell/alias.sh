#### Aliases
# Shared by bash and zsh; symlinked to ~/.config/shell/alias.sh via `stow shell`.
alias cls="clear"
command -v eza >/dev/null 2>&1 && { alias l="eza -al"; alias ls="eza"; }
command -v nvim >/dev/null 2>&1 && alias vi="nvim"
command -v bat >/dev/null 2>&1 && alias cat="bat --paging=never"
