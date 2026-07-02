#### History
HISTSIZE=100000
HISTFILESIZE=100000
# ignoreboth = ignorespace + ignoredups; erasedups clears older duplicate lines
HISTCONTROL=ignoreboth:erasedups
# Append across sessions instead of overwriting the file on exit
shopt -s histappend
