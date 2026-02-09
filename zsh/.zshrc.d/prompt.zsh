autoload -Uz compinit && compinit -C
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{blue}git:(%F{red}%b%F{blue})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}git:(%F{red}%b|%a%F{blue})%f'
setopt PROMPT_SUBST
PROMPT='%(?.%B%F{green}➜%f%b .%B%F{red}➜%f%b ) %F{cyan}%c%f${vcs_info_msg_0_} '
