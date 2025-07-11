#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <manual|auto> [package-manager]

Modes:
  manual                  List packages
  auto <pkg-manager>      Install via given manager
EOF
  exit 1
}

# Help
[[ "${1:-}" =~ ^(-h|--help)$ ]] && usage

# Args
MODE="${1:-}"; shift
case "$MODE" in
  manual) ;;
  auto)
    PKG_MANAGER="${1:-}" && shift
    [[ -z "$PKG_MANAGER" ]] && { echo "Error: auto needs a package manager"; usage; }
    ;;
  *) usage ;;
esac

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

PACKAGES=(git-delta neovim git tmux)
BIN=(delta nvim git tmux)

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

link() {
  local src="$1" dst="$2" desc="$3"
  echo "Linking $desc..."
  [[ -e "$dst" || -L "$dst" ]] && rm -rf "$dst"
  ln -s "$src" "$dst"
  echo "  $src → $dst"
}

# === Main ===
install_packages
install_tpm

link "$DOTFILES_DIR/nvim"             "$HOME/.config/nvim"      "Neovim config"
link "$DOTFILES_DIR/tmux/.tmux.conf"  "$HOME/.tmux.conf"        "tmux config"
link "$DOTFILES_DIR/git/.gitconfig"   "$HOME/.gitconfig"        "Git config"

echo "🎉 Dotfiles setup complete!"
