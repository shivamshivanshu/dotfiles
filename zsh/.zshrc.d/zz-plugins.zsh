if [[ -f "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi
