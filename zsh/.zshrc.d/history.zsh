#### History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# Write history only on shell exit — no live sharing between concurrent sessions
unsetopt SHARE_HISTORY
unsetopt INC_APPEND_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE      # commands prefixed with a space stay out of history
setopt HIST_EXPIRE_DUPS_FIRST # evict duplicates before unique entries when trimming
setopt HIST_REDUCE_BLANKS
