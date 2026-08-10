#### Paths
for d in "$HOME/.krew/bin" "$HOME/.local/bin" "$HOME/bin" "$HOME/.cargo/bin"; do
	[[ -d "$d" ]] || continue
	_p=":$PATH:"
	while [[ "$_p" == *":$d:"* ]]; do _p="${_p//:$d:/:}"; done
	_p="${_p#:}"
	_p="${_p%:}"
	PATH="$d${_p:+:$_p}"
done
unset d _p
export PATH

export COLORTERM=truecolor
export EDITOR=nvim VISUAL=nvim
