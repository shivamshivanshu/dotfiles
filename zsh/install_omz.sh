#!/usr/bin/env bash
set -euo pipefail

OMZ_DIR="${HOME}/.config/oh-my-zsh"

if [[ -d "$OMZ_DIR" ]]; then
  echo "oh-my-zsh already installed at $OMZ_DIR"
  exit 0
fi

echo "Installing oh-my-zsh to $OMZ_DIR..."
git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
echo "Done. Source it in your .zshrc with: export ZSH=\"$OMZ_DIR\""
