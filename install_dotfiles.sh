#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <manual|auto|link> [package-manager]

Modes:
  manual                  List packages (no install, no symlinks)
  auto [pkg-manager]      Install packages and symlink via GNU Stow
                          (pkg-manager auto-detected if omitted)
  link                    Only create symlinks via GNU Stow (skip package install)

Supported package managers: brew, apt, dnf, pacman, yay
EOF
  exit 1
}

[[ "${1:-}" =~ ^(-h|--help)$ ]] && usage

MODE="${1:-}"
[[ $# -gt 0 ]] && shift

PKG_MANAGER=""
case "$MODE" in
  manual|link) ;;
  auto)
    PKG_MANAGER="${1:-}"
    [[ $# -gt 0 ]] && shift
    ;;
  *) usage ;;
esac

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Each entry is "binary:package-name" — kept as parallel list for bash 3.2 compat (macOS).
PACKAGES=(
  "nvim:neovim"
  "git:git"
  "tmux:tmux"
  "fzf:fzf"
  "stow:stow"
)

CARGO_PACKAGES=(
  "atuin:atuin"
  "tree-sitter:tree-sitter-cli"
  "delta:git-delta"
  "rg:ripgrep"
  "fd:fd-find"
  "eza:eza"
  "bat:bat"
  "zoxide:zoxide"
  "tldr:tealdeer"
  "rtk:git+https://github.com/rtk-ai/rtk"
  "cargo-install-update:cargo-update"
)

STOW_PACKAGES=(nvim tmux git alacritty wezterm bash zsh claude)

detect_pkg_manager() {
  case "$(uname -s)" in
    Darwin)
      command -v brew &>/dev/null && { echo "brew"; return; }
      echo "Error: Homebrew not found on macOS. Install from https://brew.sh" >&2
      exit 1
      ;;
    Linux)
      for pm in apt dnf pacman yay; do
        command -v "$pm" &>/dev/null && { echo "$pm"; return; }
      done
      echo "Error: no supported package manager found (tried apt, dnf, pacman, yay)" >&2
      exit 1
      ;;
    *)
      echo "Error: unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

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
    echo "Package manager: $PKG_MANAGER"
    refresh_pkg_index "$PKG_MANAGER"
  fi
  for entry in "${PACKAGES[@]}"; do
    local bin="${entry%%:*}"
    local pkg="${entry#*:}"
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

install_zsh_plugins() {
  local plugin_dir="$HOME/.zsh"
  mkdir -p "$plugin_dir"
  local repo="zsh-users/zsh-autosuggestions"
  local name="${repo##*/}"
  if [[ -d "$plugin_dir/$name" ]]; then
    echo "→ zsh plugin $name already cloned"
  else
    echo "→ cloning $repo"
    git clone --depth 1 "https://github.com/$repo" "$plugin_dir/$name"
  fi
}

ensure_cargo() {
  if command -v cargo &>/dev/null; then
    return
  fi
  if [[ "$MODE" == auto ]]; then
    echo "→ cargo not found; bootstrapping rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path
    [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
    command -v cargo &>/dev/null || { echo "Error: rustup install failed; cargo still not found" >&2; exit 1; }
  else
    echo "Error: cargo not found. CARGO_PACKAGES require cargo (rustup provides it)." >&2
    echo "       Run '$0 auto' to bootstrap rustup, or install manually:" >&2
    echo "       curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" >&2
    exit 1
  fi
}

install_cargo_packages() {
  ensure_cargo
  for entry in "${CARGO_PACKAGES[@]}"; do
    local bin="${entry%%:*}"
    local crate="${entry#*:}"
    echo "→ $bin (cargo: $crate)"
    if [[ "$MODE" == auto ]]; then
      if command -v "$bin" &>/dev/null; then
        echo "   already installed"
      else
        echo "   installing via cargo (may take several minutes)..."
        if [[ "$crate" == git+* ]]; then
          cargo install --git "${crate#git+}" --root "$HOME/.local" --locked
        else
          cargo install "$crate" --root "$HOME/.local" --locked
        fi
      fi
    fi
  done
}

stow_packages() {
  if ! command -v stow &>/dev/null; then
    echo "Error: GNU Stow is not installed. Install it first (e.g. '$0 auto')." >&2
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
if [[ "$MODE" == auto && -z "$PKG_MANAGER" ]]; then
  PKG_MANAGER="$(detect_pkg_manager)"
fi

if [[ "$MODE" != "link" ]]; then
  install_packages
  install_cargo_packages
fi

if [[ "$MODE" != "manual" ]]; then
  stow_packages
fi

if [[ "$MODE" == "auto" ]]; then
  install_tpm
  install_zsh_plugins
fi

echo "Dotfiles setup complete!"
