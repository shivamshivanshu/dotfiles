#!/usr/bin/env bash
# Exercises install_dotfiles.sh's pure helpers against stubbed brew/cargo/go/sudo,
# so the install paths are covered without touching the system. Run: tests/install_functions_test.sh
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FUNCS="$(mktemp)"
trap 'rm -f "$FUNCS"' EXIT

# Everything above the dispatch block is definitions plus the manifest.
sed '/^##### Dispatch #####/,$d' "$REPO/install_dotfiles.sh" >"$FUNCS"
# The sourced prelude parses "$@" itself, so hand it a mode that does no work.
set -- check
# shellcheck source=/dev/null
source "$FUNCS"
# The prelude derives this from $0, which is this script, not the repo root.
DOTFILES_DIR="$REPO"

pass=0
fail=0
ok() {
	if [[ "$2" == "$3" ]]; then
		echo "✓ $1"
		pass=$((pass + 1))
	else
		echo "✗ $1"
		echo "   want: $3"
		echo "   got:  $2"
		fail=$((fail + 1))
	fi
}

# system_package_name maps a binary to its per-manager package name.
ok "go on apt" "$(system_package_name apt go go)" "golang-go"
ok "go on dnf" "$(system_package_name dnf go go)" "golang"
ok "go on brew" "$(system_package_name brew go go)" "go"
ok "tap-qualified cask passes through" \
	"$(system_package_name brew aerospace nikitabobko/tap/aerospace)" "nikitabobko/tap/aerospace"
ok "nvim passes through" "$(system_package_name apt nvim neovim)" "neovim"

# install_missing skips binaries already on PATH and installs the rest.
fake_install() { echo "INSTALL:$1"; }
ok "present binary is skipped" \
	"$(install_missing cargo fake_install "git:git" | tr '\n' '|')" \
	"→ git (cargo: git)|   already installed|"
ok "absent binary is installed from its spec" \
	"$(install_missing cargo fake_install "zzz-no-such-bin:some-crate" | tr '\n' '|')" \
	"→ zzz-no-such-bin (cargo: some-crate)|INSTALL:some-crate|"
ok "every entry is visited" \
	"$(install_missing go fake_install "zzz-a:mod-a" "zzz-b:mod-b" | grep -c INSTALL)" "2"

cargo() { echo "cargo $*"; }
ok "registry crate" "$(cargo_install ripgrep | tail -1)" \
	"cargo install ripgrep --root $HOME/.local --locked"
ok "git+ crate uses --git without the prefix" \
	"$(cargo_install 'git+https://github.com/rtk-ai/rtk' | tail -1)" \
	"cargo install --git https://github.com/rtk-ai/rtk --root $HOME/.local --locked"

go() { echo "go $* GOBIN=$GOBIN"; }
ok "go install targets ~/.local/bin" \
	"$(go_install 'mvdan.cc/sh/v3/cmd/shfmt@latest')" \
	"go install mvdan.cc/sh/v3/cmd/shfmt@latest GOBIN=$HOME/.local/bin"

# install_or_upgrade_package upgrades an existing brew package, installs otherwise.
brew() {
	case "$1" in
	list) return 0 ;;
	*) echo "brew $*" ;;
	esac
}
ok "brew package already present is upgraded" "$(install_or_upgrade_package brew fzf)" "brew upgrade fzf"
brew() {
	case "$1" in
	list) return 1 ;;
	*) echo "brew $*" ;;
	esac
}
ok "brew package absent is installed" "$(install_or_upgrade_package brew fzf)" "brew install fzf"
sudo() { echo "sudo $*"; }
ok "apt goes through install_package" "$(install_or_upgrade_package apt neovim)" "sudo apt install -y neovim"

# install_local_packages walks both manifests; the installers are stubbed so a
# genuinely missing crate is not built for real.
ensure_cargo() { :; }
cargo_install() { echo "CARGO:$1"; }
go_install() { echo "GO:$1"; }
ok "local packages cover the cargo manifest" \
	"$(install_local_packages | grep -c '(cargo: ')" "${#CARGO_PACKAGES[@]}"
ok "local packages cover the go manifest" \
	"$(install_local_packages | grep -c '(go: ')" "${#GO_PACKAGES[@]}"

# pre_install_setup adds the platform's extra package sources.
brew() { echo "brew $*"; }
OS=Darwin
ok "macOS taps the aerospace cask" "$(pre_install_setup)" "brew tap nikitabobko/tap"
OS=Linux
ok "Linux needs no extra source" "$(pre_install_setup)" ""
OS=FreeBSD
ok "unknown OS is a no-op" "$(pre_install_setup)" ""

# register_platform_packages is what puts aerospace in the macOS manifest.
SYSTEM_PACKAGES=("git:git")
STOW_PACKAGES=(nvim)
OS=Darwin
register_platform_packages
ok "macOS registers the aerospace package" "${SYSTEM_PACKAGES[*]}" "git:git aerospace:nikitabobko/tap/aerospace"
ok "macOS registers the aerospace stow package" "${STOW_PACKAGES[*]}" "nvim aerospace"
SYSTEM_PACKAGES=("git:git")
STOW_PACKAGES=(nvim)
OS=FreeBSD
register_platform_packages
ok "unknown OS registers nothing extra" "${SYSTEM_PACKAGES[*]} / ${STOW_PACKAGES[*]}" "git:git / nvim"

# prepare_zsh runs against a live ~/.zshenv, so it must never destroy a divergent one.
exists() { [[ -e "$1" ]] && echo yes || echo no; }
REAL_HOME="$HOME"
SANDBOX_HOME="$(mktemp -d)"
trap 'rm -f "$FUNCS"; rm -rf "$SANDBOX_HOME"' EXIT
HOME="$SANDBOX_HOME"
printf 'machine local\n' >"$HOME/.zshenv"
prepare_zsh >/dev/null
ok "divergent .zshenv is kept as .pre-stow" "$(cat "$HOME/.zshenv.pre-stow")" "machine local"
ok "divergent .zshenv frees the stow target" "$(exists "$HOME/.zshenv")" "no"

rm -f "$HOME/.zshenv.pre-stow"
cp "$REPO/zsh/.zshenv" "$HOME/.zshenv"
prepare_zsh >/dev/null
ok "identical .zshenv is dropped outright" "$(exists "$HOME/.zshenv")/$(exists "$HOME/.zshenv.pre-stow")" "no/no"

ln -s "$REPO/zsh/.zshenv" "$HOME/.zshenv"
prepare_zsh >/dev/null
ok "already-stowed .zshenv is left alone" "$(readlink "$HOME/.zshenv")" "$REPO/zsh/.zshenv"
HOME="$REAL_HOME"

echo
echo "passed=$pass failed=$fail"
[[ $fail -eq 0 ]]
