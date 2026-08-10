#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<EOF
Usage: $0 <manual|auto|link|check> [package-manager]

Modes:
  manual                  List the required command/dependency manifest (no changes)
  auto [pkg-manager]      Install every required dependency and symlink via GNU Stow
                          (pkg-manager auto-detected if omitted)
  link                    Only create symlinks via GNU Stow (skip package install)
  check                   Verify every required command is available (no changes)

Supported package managers: brew, apt, dnf, pacman, yay
EOF
	exit 1
}

[[ "${1:-}" =~ ^(-h|--help)$ ]] && usage

MODE="${1:-}"
[[ $# -gt 0 ]] && shift

PKG_MANAGER=""
case "$MODE" in
manual | link | check) ;;
auto)
	PKG_MANAGER="${1:-}"
	[[ $# -gt 0 ]] && shift
	case "$PKG_MANAGER" in
	"") ;;
	brew | apt | dnf | pacman | yay)
		command -v "$PKG_MANAGER" &>/dev/null || {
			echo "Error: $PKG_MANAGER not found on this system" >&2
			exit 1
		}
		;;
	*)
		echo "Error: unsupported package manager: $PKG_MANAGER (supported: brew, apt, dnf, pacman, yay)" >&2
		exit 1
		;;
	esac
	;;
*) usage ;;
esac

[[ $# -eq 0 ]] || {
	echo "Error: unexpected argument: $1" >&2
	usage
}

##### Manifest #####

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"
export PATH="$HOME/.local/bin:$PATH"

MIN_NVIM_VERSION="0.12.0"
MIN_TMUX_VERSION="3.2.0"

# Required commands and their package names; Bash 3.2 has no associative arrays.
SYSTEM_PACKAGES=(
	"curl:curl"
	"nvim:neovim"
	"git:git"
	"tmux:tmux"
	"fzf:fzf"
	"direnv:direnv"
	"stow:stow"
	"wezterm:wezterm"
	"zsh:zsh"
	"go:go"
)

CARGO_PACKAGES=(
	"atuin:atuin"
	"stylua:stylua"
	"tree-sitter:tree-sitter-cli"
	"delta:git-delta"
	"rg:ripgrep"
	"ast-grep:ast-grep"
	"fd:fd-find"
	"eza:eza"
	"bat:bat"
	"zoxide:zoxide"
	"tldr:tealdeer"
	"iwe:iwe"
	"iwes:iwes"
	"rtk:git+https://github.com/rtk-ai/rtk"
	"cargo-install-update:cargo-update"
)

GO_PACKAGES=(
	"shfmt:mvdan.cc/sh/v3/cmd/shfmt@latest"
)

# Alacritty is provided by the OS; only its config is linked.
STOW_PACKAGES=(nvim tmux git alacritty wezterm bash zsh claude shell scripts ssh)

# Platform-specific requirements. Registering them up front (rather than while
# installing) keeps 'manual' and 'check' honest about what this host needs.
register_platform_packages() {
	case "$OS" in
	Darwin)
		SYSTEM_PACKAGES+=("aerospace:nikitabobko/tap/aerospace")
		STOW_PACKAGES+=(aerospace)
		;;
	Linux)
		if [[ -f /etc/fedora-release ]]; then
			STOW_PACKAGES+=(dnf)
		fi
		;;
	esac
}

register_platform_packages

##### Platform #####

# Extra package sources the manifest depends on; run before installing anything.
pre_install_setup_mac() {
	brew tap nikitabobko/tap
}

pre_install_setup_linux() {
	: # no extra package sources needed yet
}

pre_install_setup() {
	case "$OS" in
	Darwin) pre_install_setup_mac ;;
	Linux) pre_install_setup_linux ;;
	esac
}

detect_pkg_manager() {
	case "$OS" in
	Darwin)
		command -v brew &>/dev/null && {
			echo "brew"
			return
		}
		echo "Error: Homebrew not found on macOS. Install from https://brew.sh" >&2
		exit 1
		;;
	Linux)
		for pm in apt dnf pacman yay; do
			command -v "$pm" &>/dev/null && {
				echo "$pm"
				return
			}
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
	apt) sudo apt update ;;
	pacman) sudo pacman -Sy ;;
	esac
}

##### Version checks #####

version_at_least() {
	local actual required a_major a_minor a_patch r_major r_minor r_patch
	actual="$(printf '%s' "$1" | sed -E 's/^[^0-9]*//; s/[^0-9.].*$//')"
	required="$2"
	IFS=. read -r a_major a_minor a_patch <<<"$actual"
	IFS=. read -r r_major r_minor r_patch <<<"$required"
	a_major="${a_major:-0}"
	a_minor="${a_minor:-0}"
	a_patch="${a_patch:-0}"
	r_major="${r_major:-0}"
	r_minor="${r_minor:-0}"
	r_patch="${r_patch:-0}"

	((a_major > r_major || (\
	a_major == r_major && a_minor > r_minor) || (\
	a_major == r_major && a_minor == r_minor && a_patch >= r_patch)))
}

nvim_version() { NVIM_LOG_FILE=/dev/null nvim --version | sed -n '1s/.*v\([^ ]*\).*/\1/p'; }
tmux_version() { tmux -V | sed -E 's/^[^0-9]*//'; }

tool_is_current() {
	local bin="$1"
	command -v "$bin" &>/dev/null || return 1
	case "$bin" in
	nvim) version_at_least "$(nvim_version)" "$MIN_NVIM_VERSION" ;;
	tmux) version_at_least "$(tmux_version)" "$MIN_TMUX_VERSION" ;;
	*) true ;;
	esac
}

##### System packages #####

install_package() {
	local pm="$1" pkg="$2"
	case "$pm" in
	brew) brew install "$pkg" ;;
	apt) sudo apt install -y "$pkg" ;;
	dnf) sudo dnf install -y "$pkg" ;;
	pacman) sudo pacman -S --needed --noconfirm "$pkg" ;;
	yay) yay -S --needed --noconfirm "$pkg" ;;
	esac
}

system_package_name() {
	local pm="$1" bin="$2" pkg="$3"
	case "$bin:$pm" in
	go:apt) echo "golang-go" ;;
	go:dnf) echo "golang" ;;
	*) echo "$pkg" ;;
	esac
}

install_or_upgrade_package() {
	local pm="$1" pkg="$2"
	if [[ "$pm" == brew ]] && brew list --versions "$pkg" &>/dev/null; then
		brew upgrade "$pkg"
	else
		install_package "$pm" "$pkg"
	fi
}

list_requirements() {
	local entry
	echo "Required system packages:"
	for entry in "${SYSTEM_PACKAGES[@]}"; do
		echo "  $(system_package_name "$PKG_MANAGER" "${entry%%:*}" "${entry#*:}") (${entry%%:*})"
	done

	echo "Required Cargo packages (installed to ~/.local):"
	for entry in "${CARGO_PACKAGES[@]}"; do
		echo "  ${entry#*:} (${entry%%:*})"
	done

	echo "Required Go packages (installed to ~/.local):"
	for entry in "${GO_PACKAGES[@]}"; do
		echo "  ${entry#*:} (${entry%%:*})"
	done

	echo "Alacritty: config is linked, binary is provided by the operating system."
}

install_system_packages() {
	echo "Package manager: $PKG_MANAGER"
	pre_install_setup
	refresh_pkg_index "$PKG_MANAGER"
	local entry bin pkg
	for entry in "${SYSTEM_PACKAGES[@]}"; do
		bin="${entry%%:*}"
		pkg="$(system_package_name "$PKG_MANAGER" "$bin" "${entry#*:}")"
		echo "→ $bin ($pkg)"
		if tool_is_current "$bin"; then
			echo "   already installed"
			continue
		fi
		command -v "$bin" &>/dev/null && echo "   upgrading to the required version..."
		install_or_upgrade_package "$PKG_MANAGER" "$pkg"
		if ! tool_is_current "$bin"; then
			echo "Error: $bin is still missing or below the required version after installing $pkg." >&2
			exit 1
		fi
	done
}

##### Local packages (~/.local) #####

# Installs one entry per missing binary; "$installer <spec>" does the actual work.
install_missing() {
	local kind="$1" installer="$2"
	shift 2
	local entry bin
	for entry in "$@"; do
		bin="${entry%%:*}"
		echo "→ $bin ($kind: ${entry#*:})"
		if command -v "$bin" &>/dev/null; then
			echo "   already installed"
		else
			"$installer" "${entry#*:}"
		fi
	done
}

ensure_cargo() {
	if command -v cargo &>/dev/null; then
		return
	fi
	echo "→ cargo not found; bootstrapping rustup..."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path
	# shellcheck source=/dev/null
	[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
	command -v cargo &>/dev/null || {
		echo "Error: rustup install failed; cargo still not found" >&2
		exit 1
	}
}

cargo_install() {
	local crate="$1"
	echo "   installing via cargo (may take several minutes)..."
	if [[ "$crate" == git+* ]]; then
		cargo install --git "${crate#git+}" --root "$HOME/.local" --locked
	else
		cargo install "$crate" --root "$HOME/.local" --locked
	fi
}

go_install() {
	GOBIN="$HOME/.local/bin" go install "$1"
}

install_local_packages() {
	ensure_cargo
	install_missing cargo cargo_install "${CARGO_PACKAGES[@]}"
	install_missing go go_install "${GO_PACKAGES[@]}"
}

##### Plugins and git hooks #####

install_tpm() {
	local tpm_dir="$HOME/.tmux/plugins/tpm"
	if [[ -d "$tpm_dir" ]]; then
		echo "TPM already present"
	else
		echo "Installing TPM..."
		git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
	fi
	[[ -x "$tpm_dir/bin/install_plugins" ]] || {
		echo "Error: TPM is incomplete: $tpm_dir/bin/install_plugins is missing." >&2
		exit 1
	}
	"$tpm_dir/bin/install_plugins"
}

install_zsh_plugins() {
	local plugin_dir="$HOME/.zsh"
	local repo="zsh-users/zsh-autosuggestions"
	local target="$plugin_dir/zsh-autosuggestions"
	[[ -d "$target" ]] && {
		echo "→ zsh plugin zsh-autosuggestions already cloned"
		return
	}
	mkdir -p "$plugin_dir"
	echo "→ cloning $repo"
	git clone --depth 1 "https://github.com/$repo" "$target"
}

install_git_hooks() {
	git -C "$DOTFILES_DIR" config core.hooksPath .githooks
}

install_plugins() {
	install_tpm
	install_zsh_plugins
}

##### Verification #####

check_requirements() {
	local missing=0
	local entry bin

	echo "Checking required commands:"
	for entry in "${SYSTEM_PACKAGES[@]}" "${CARGO_PACKAGES[@]}" "${GO_PACKAGES[@]}"; do
		bin="${entry%%:*}"
		if tool_is_current "$bin"; then
			echo "✓ $bin"
		elif command -v "$bin" &>/dev/null; then
			case "$bin" in
			nvim) echo "✗ nvim $(nvim_version) is too old (need >= $MIN_NVIM_VERSION)" >&2 ;;
			tmux) echo "✗ tmux $(tmux_version) is too old (need >= $MIN_TMUX_VERSION)" >&2 ;;
			esac
			missing=1
		else
			echo "✗ $bin is missing" >&2
			missing=1
		fi
	done

	if ((missing)); then
		echo "Run '$0 auto' to install missing dependencies." >&2
		return 1
	fi
}

##### Stow #####

# Preserve a divergent real file; remove one already identical to the tracked file.
preserve_pre_stow() {
	local live="$1" tracked="$2"
	[[ -f "$live" && ! -L "$live" ]] || return 0
	if cmp -s "$live" "$tracked"; then
		rm "$live"
	else
		echo "→ preserving $(basename "$live") as $(basename "$live").pre-stow"
		mv "$live" "$live.pre-stow"
	fi
}

# Keep ~/.ssh real for keys and known_hosts.
prepare_ssh() {
	mkdir -p "$HOME/.ssh/sockets"
	chmod 700 "$HOME/.ssh" "$HOME/.ssh/sockets"
	preserve_pre_stow "$HOME/.ssh/config" "$DOTFILES_DIR/ssh/.ssh/config"
}

# Claude can replace this symlink with a real settings file.
prepare_claude() {
	local live="$HOME/.claude/settings.json"
	[[ -L "$live" && ! -e "$live" ]] && rm "$live"
	preserve_pre_stow "$live" "$DOTFILES_DIR/claude/.claude/settings.json"
}

# DevEnv boxes ship a hand-written ~/.zshenv.
prepare_zsh() {
	preserve_pre_stow "$HOME/.zshenv" "$DOTFILES_DIR/zsh/.zshenv"
}

stow_packages() {
	if ! command -v stow &>/dev/null; then
		echo "Error: GNU Stow is not installed. Install it first (e.g. '$0 auto')." >&2
		exit 1
	fi
	mkdir -p "$HOME/.config"
	prepare_claude
	prepare_ssh
	prepare_zsh
	for pkg in "${STOW_PACKAGES[@]}"; do
		echo "→ stow $pkg"
		local flags=(--restow --target="$HOME" --dir="$DOTFILES_DIR" --ignore='__pycache__')
		# Keep runtime state and secrets outside the repo.
		[[ "$pkg" == claude || "$pkg" == ssh ]] && flags+=(--no-folding)
		stow "${flags[@]}" "$pkg"
	done
}

##### Dispatch #####

if [[ "$MODE" == auto && -z "$PKG_MANAGER" ]]; then
	PKG_MANAGER="$(detect_pkg_manager)"
fi

case "$MODE" in
manual)
	list_requirements
	;;
auto)
	install_system_packages
	install_local_packages
	stow_packages
	install_git_hooks
	install_plugins
	check_requirements
	echo "Dotfiles setup complete!"
	;;
link)
	stow_packages
	install_git_hooks
	echo "Dotfiles linked!"
	;;
check)
	check_requirements
	echo "All required commands are available."
	;;
esac
