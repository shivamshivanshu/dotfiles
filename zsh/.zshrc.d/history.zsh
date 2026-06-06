#### History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# Write history only on shell exit — no live sharing between concurrent sessions
unsetopt SHARE_HISTORY
unsetopt INC_APPEND_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
