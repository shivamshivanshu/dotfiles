#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <manual|auto|link> [package-manager]

Modes:
  manual                  List packages (no install, no symlinks)
  auto <pkg-manager>      Install packages and symlink via GNU Stow
  link                    Only create symlinks via GNU Stow (skip package install)

Supported package managers: brew, apt, dnf, pacman, yay
EOF
  exit 1
}

[[ "${1:-}" =~ ^(-h|--help)$ ]] && usage

MODE="${1:-}"
[[ $# -gt 0 ]] && shift
case "$MODE" in
  manual|link) ;;
  auto)
    PKG_MANAGER="${1:-}"
    [[ -z "$PKG_MANAGER" ]] && { echo "Error: auto needs a package manager"; usage; }
    shift
    ;;
  *) usage ;;
esac

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

declare -A PACKAGES=(
  [delta]=git-delta
  [nvim]=neovim
  [git]=git
  [tmux]=tmux
  [rg]=ripgrep
  [eza]=eza
  [fzf]=fzf
  [bat]=bat
  [zoxide]=zoxide
  [stow]=stow
)

STOW_PACKAGES=(nvim tmux git alacritty wezterm bash zsh)

refresh_pkg_index() {
  local pm="$1"
  case "$pm" in
    apt)    sudo apt update ;;
    pacman) sudo pacman -Sy ;;
  esac
}

install_package() {
  local pm="$1" pkg="$2"
  case "$pm" in
    brew)   brew install "$pkg" ;;
    apt)    sudo apt install -y "$pkg" ;;
    dnf)    sudo dnf install -y "$pkg" ;;
    pacman) sudo pacman -S --needed --noconfirm "$pkg" ;;
    yay)    yay -S --needed --noconfirm "$pkg" ;;
    *)
      echo "Unsupported manager: $pm; please install $pkg manually."
      return 1
      ;;
  esac
}

install_packages() {
  echo "Mode: $MODE"
  if [[ "$MODE" == auto ]]; then
    refresh_pkg_index "$PKG_MANAGER"
  fi
  for bin in "${!PACKAGES[@]}"; do
    local pkg="${PACKAGES[$bin]}"
    echo "→ $bin ($pkg)"
    if [[ "$MODE" == auto ]]; then
      if command -v "$bin" &>/dev/null; then
        echo "   already installed"
      else
        install_package "$PKG_MANAGER" "$pkg"
      fi
    fi
  done
}

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [[ -d "$tpm_dir" ]]; then
    echo "TPM already present"
  else
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi
  if [[ -x "$tpm_dir/bin/install_plugins" ]]; then
    "$tpm_dir/bin/install_plugins" || echo "TPM plugin install failed (run tmux and press prefix+I)"
  fi
}

stow_packages() {
  if ! command -v stow &>/dev/null; then
    echo "Error: GNU Stow is not installed. Install it first (e.g. '$0 auto <pkg-mgr>')." >&2
    exit 1
  fi
  mkdir -p "$HOME/.config"
  cd "$DOTFILES_DIR"
  for pkg in "${STOW_PACKAGES[@]}"; do
    echo "→ stow $pkg"
    stow --restow --target="$HOME" --dir="$DOTFILES_DIR" "$pkg"
  done
}

# === Main ===
if [[ "$MODE" != "link" ]]; then
  install_packages
fi

if [[ "$MODE" != "manual" ]]; then
  stow_packages
fi

if [[ "$MODE" == "auto" ]]; then
  install_tpm
fi

echo "Dotfiles setup complete!"
