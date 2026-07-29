#### Aliases
alias cls="clear"
alias vim="nvim"
command -v eza >/dev/null 2>&1 && { alias l="eza -al"; alias ls="eza"; }
command -v nvim >/dev/null 2>&1 && alias vi="nvim"
command -v bat >/dev/null 2>&1 && alias cat="bat --paging=never"

command -v cheatsheet.py >/dev/null 2>&1 && alias cheatsheet="cheatsheet.py"
