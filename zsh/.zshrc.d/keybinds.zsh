#### Edit the command line in $EDITOR
# Sourced after config.zsh so these win over atuin's bindings.
# ^O and ^P are free at every layer: tmux takes C-a/h/j/k/l/\, wezterm takes
# C-m, atuin takes ^R, and history nav here runs off the arrows and vicmd j/k.
# Pin vi mode. Without this zsh infers the keymap from $EDITOR containing the
# substring "vi", so renaming the editor would silently flip the shell to emacs
# keys. The binds below name their keymaps, so they survive either way.
bindkey -v

autoload -Uz edit-command-line
zle -N edit-command-line

# Replays the previous command through the editor, running it only if it came
# back changed — so quitting the editor leaves it on the prompt instead of
# executing something the user never edited.
edit-last-command-line() {
	local seeded=${history[$((HISTCMD - 1))]}
	BUFFER=$seeded
	CURSOR=$#BUFFER
	zle edit-command-line
	[[ -n $BUFFER && $BUFFER != $seeded ]] && zle accept-line
}
zle -N edit-last-command-line

for _keymap in viins vicmd; do
	bindkey -M $_keymap '^O' edit-command-line
	bindkey -M $_keymap '^P' edit-last-command-line
done
unset _keymap
