#!/usr/bin/env bash

set -e  # Exit on any error

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"  # Get absolute path to dotfiles directory

echo "Dotfiles directory: $DOTFILES_DIR"

# === Install TPM (Tmux Plugin Manager) ===
TPM_PATH="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_PATH" ]; then
  echo "📦 Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
else
  echo "TPM already installed at $TPM_PATH"
fi

# === Link Neovim config ===
NVIM_SOURCE="$DOTFILES_DIR/nvim"
NVIM_TARGET="$HOME/.config/nvim"

echo "Linking Neovim config..."
mkdir -p "$HOME/.config"

if [ -e "$NVIM_TARGET" ] || [ -L "$NVIM_TARGET" ]; then
  echo "Removing existing Neovim config at $NVIM_TARGET"
  rm -rf "$NVIM_TARGET"
fi

ln -s "$NVIM_SOURCE" "$NVIM_TARGET"
echo "Linked $NVIM_SOURCE → $NVIM_TARGET"

# === Link tmux config ===
TMUX_CONF_SOURCE="$DOTFILES_DIR/tmux/.tmux.conf"
TMUX_CONF_TARGET="$HOME/.tmux.conf"

echo "Linking tmux config..."
if [ -e "$TMUX_CONF_TARGET" ] || [ -L "$TMUX_CONF_TARGET" ]; then
  echo "Removing existing tmux config at $TMUX_CONF_TARGET"
  rm -f "$TMUX_CONF_TARGET"
fi

ln -s "$TMUX_CONF_SOURCE" "$TMUX_CONF_TARGET"
echo "Linked $TMUX_CONF_SOURCE → $TMUX_CONF_TARGET"

echo ""
echo "Dotfiles setup complete!"
