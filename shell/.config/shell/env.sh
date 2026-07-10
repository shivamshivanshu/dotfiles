#### Paths
for d in "$HOME/.local/bin" "$HOME/bin" "$HOME/.cargo/bin"; do
  [[ -d "$d" && ":$PATH:" != *":$d:"* ]] && PATH="$d:$PATH"
done
export PATH

export COLORTERM=truecolor
export EDITOR=nvim VISUAL=nvim
