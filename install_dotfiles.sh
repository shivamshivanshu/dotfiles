#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <manual|auto|link> [package-manager]

Modes:
  manual                  List packages
  auto <pkg-manager>      Install via given manager
  link                    Only create symlinks (skip package install)
EOF
  exit 1
}

# Help
[[ "${1:-}" =~ ^(-h|--help)$ ]] && usage

# Args
MODE="${1:-}"; shift
case "$MODE" in
  manual|link) ;;
  auto)
    PKG_MANAGER="${1:-}" && shift
    [[ -z "$PKG_MANAGER" ]] && { echo "Error: auto needs a package manager"; usage; }
    ;;
  *) usage ;;
esac

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

PACKAGES=(git-delta neovim git tmux ripgrep eza fzf bat zoxide)
BIN=(delta nvim git tmux rg eza fzf bat zoxide)

install_package() {
  local pm="$1" pkg="$2"
  case "$pm" in
    brew)   brew install "$pkg" ;;
    apt)    sudo apt update && sudo apt install -y "$pkg" ;;
    dnf)    sudo dnf install -y "$pkg" ;;
    pacman) sudo pacman -Sy "$pkg" --noconfirm ;;
    yay)    yay -S --noconfirm "$pkg" ;;
    *)
      echo "Unsupported manager: $pm; please install $pkg manually."
      return 1
      ;;
  esac
}

install_packages() {
  echo "Mode: $MODE"
  for i in "${!PACKAGES[@]}"; do
    pkg="${PACKAGES[i]}"
    bin="${BIN[i]}"
    echo "→ $bin"
    if [[ "$MODE" == auto ]]; then
      if ! command -v "$bin" &>/dev/null; then
        install_package "$PKG_MANAGER" "$pkg"
      else
        echo "   $bin already installed"
      fi
    fi
  done
}

install_tpm() {
  local p="$HOME/.tmux/plugins/tpm"
  [[ -d "$p" ]] && { echo "TPM already present"; return; }
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$p"
}

confirm() {
  local prompt="$1"
  read -rp "$prompt [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

link() {
  local src="$1" dst="$2" desc="$3"
  confirm "Link $desc ($src → $dst)?" || { echo "  Skipped"; return; }
  [[ -e "$dst" || -L "$dst" ]] && rm -rf "$dst"
  ln -s "$src" "$dst"
  echo "  Linked"
}

# === Main ===
if [[ "$MODE" != "link" ]]; then
  install_packages
  install_tpm
fi

link "$DOTFILES_DIR/nvim"             "$HOME/.config/nvim"           "Neovim config"
link "$DOTFILES_DIR/tmux/.tmux.conf"  "$HOME/.tmux.conf"            "tmux config"
link "$DOTFILES_DIR/git/.gitconfig"   "$HOME/.gitconfig"            "Git config"
link "$DOTFILES_DIR/alacritty"        "$HOME/.config/alacritty"     "Alacritty config"
link "$DOTFILES_DIR/wezterm"          "$HOME/.config/wezterm"       "Wezterm config"
link "$DOTFILES_DIR/bash/.bashrc"     "$HOME/.bashrc"               "Bash config"
link "$DOTFILES_DIR/bash/.bashrc.d"   "$HOME/.bashrc.d"             "Bash modular configs"
link "$DOTFILES_DIR/zsh/.zshrc.user"  "$HOME/.zshrc.user"           "Zsh user config"
link "$DOTFILES_DIR/zsh/.zshrc.d"     "$HOME/.zshrc.d"              "Zsh modular configs"

echo "Dotfiles setup complete!"
