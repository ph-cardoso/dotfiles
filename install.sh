#!/usr/bin/env bash
# Linux/macOS/WSL bootstrap. Configuration-only mode never accesses the network.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_HOME="${DOTFILES_TARGET_HOME:-$HOME}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$DEST_HOME/.config}"
SKIP_PACKAGES=0; SKIP_RUNTIMES=0; SKIP_PLUGINS=0; CONFIG_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --skip-packages) SKIP_PACKAGES=1 ;;
    --skip-runtimes) SKIP_RUNTIMES=1 ;;
    --skip-plugins) SKIP_PLUGINS=1 ;;
    --config-only) CONFIG_ONLY=1; SKIP_PACKAGES=1; SKIP_RUNTIMES=1; SKIP_PLUGINS=1 ;;
    --help|-h) printf '%s\n' 'Usage: bash install.sh [--config-only] [--skip-packages] [--skip-runtimes] [--skip-plugins]'; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; exit 2 ;;
  esac
done
info() { printf '==> %s\n' "$*"; }
warn() { printf '  ! %s\n' "$*" >&2; }
OS=unknown; IS_WSL=0
case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux) OS=linux; if grep -qiE 'microsoft|wsl' /proc/sys/kernel/osrelease 2>/dev/null; then IS_WSL=1; fi ;;
  *) warn 'Use install.ps1 from PowerShell 7 on native Windows.'; exit 1 ;;
esac

# Never discard a newer config just because an older backup exists.
backup() {
  local dest="$1" suffix
  if [[ -e "$dest" || -L "$dest" ]]; then
    suffix="$(date +%Y%m%d%H%M%S).$$"
    while [[ -e "$dest.bak.$suffix" || -L "$dest.bak.$suffix" ]]; do suffix="$suffix.1"; done
    mv "$dest" "$dest.bak.$suffix"
    info "Backed up $dest -> $dest.bak.$suffix"
  fi
}
link() {
  local src="$DOTFILES/$1" dest="$2"
  # Comparing absolute link targets works with BSD readlink (no GNU -f required).
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then return; fi
  mkdir -p "$(dirname "$dest")"
  backup "$dest"
  ln -s "$src" "$dest"
  info "Linked $dest"
}
copy_config() {
  local src="$1" dest="$2"
  if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then return; fi
  mkdir -p "$(dirname "$dest")"
  backup "$dest"
  cp "$src" "$dest"
}

load_brew() {
  local brew_bin
  if command -v brew >/dev/null 2>&1; then brew_bin="$(command -v brew)";
  elif [[ -x /opt/homebrew/bin/brew ]]; then brew_bin=/opt/homebrew/bin/brew;
  elif [[ -x /usr/local/bin/brew ]]; then brew_bin=/usr/local/bin/brew;
  elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then brew_bin=/home/linuxbrew/.linuxbrew/bin/brew;
  else return 1; fi
  eval "$("$brew_bin" shellenv)"
}
install_brew() {
  if ! load_brew; then
    info 'Installing Homebrew (system build prerequisites may be required)'
    local installer
    installer="$(mktemp)"
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"
    NONINTERACTIVE=1 /bin/bash "$installer"
    rm -f "$installer"
    load_brew
  fi
  brew bundle --no-upgrade --file="$DOTFILES/Brewfile"
}

setup_git() {
  command -v git >/dev/null || { warn 'Git is required'; exit 1; }
  if [[ ! -e "$DEST_HOME/.gitconfig.local" ]]; then cp "$DOTFILES/.gitconfig.local.example" "$DEST_HOME/.gitconfig.local"; fi
  # Existing identity, SSH transport and credentials stay in the original file.
  # Include the portable config without replacing it or enabling placeholder signing.
  local config="$DEST_HOME/.gitconfig" temp
  if [[ -L "$config" && "$(readlink "$config")" == "$DOTFILES/.gitconfig" ]]; then return; fi
  if git config --file "$config" --get-all include.path 2>/dev/null | grep -Fxq "$DOTFILES/.gitconfig"; then return; fi
  temp="$(mktemp)"
  if [[ -f "$config" ]]; then cat "$config" > "$temp"; fi
  git config --file "$temp" --add include.path "$DOTFILES/.gitconfig"
  copy_config "$temp" "$config"
  rm -f "$temp"
}
link_dotfiles() {
  local name file profile_dir
  mkdir -p "$DEST_HOME" "$CONFIG_HOME" "$DEST_HOME/.local/bin"
  link .zshrc "$DEST_HOME/.zshrc"
  link .zsh "$DEST_HOME/.zsh"
  for name in tmux bat eza mise nvim fd; do link ".config/$name" "$CONFIG_HOME/$name"; done
  link .config/starship.toml "$CONFIG_HOME/starship.toml"
  link .config/wezterm/.wezterm.lua "$DEST_HOME/.wezterm.lua"
  # Do not replace the whole powershell directory: it can contain local profiles/modules.
  profile_dir="$CONFIG_HOME/powershell"
  if [[ -z "${DOTFILES_TARGET_HOME:-}" ]] && command -v pwsh >/dev/null 2>&1; then
    # $PROFILE is evaluated by PowerShell.
    # shellcheck disable=SC2016
    profile_dir="$(pwsh -NoLogo -NoProfile -Command 'Split-Path $PROFILE.CurrentUserAllHosts')"
  fi
  link .config/powershell/profile.ps1 "$profile_dir/profile.ps1"
  for name in path theme functions interactive; do link ".config/powershell/$name.ps1" "$profile_dir/$name.ps1"; done
  for file in "$DOTFILES"/bin/*; do
    [[ -f "$file" ]] || continue
    case "$(basename "$file")" in wsl-*) [[ $IS_WSL == 1 ]] || continue ;; esac
    link "bin/$(basename "$file")" "$DEST_HOME/.local/bin/$(basename "$file")"
  done
  setup_git
}
install_zsh_plugins() {
  local pdir="$DOTFILES/.zsh/plugins"
  mkdir -p "$pdir"
  if [[ ! -d "$pdir/zsh-autosuggestions" ]]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$pdir/zsh-autosuggestions"
  fi
  if [[ ! -d "$pdir/fast-syntax-highlighting" ]]; then
    git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting "$pdir/fast-syntax-highlighting"
  fi
}
install_wsl_helpers() {
  [[ $IS_WSL == 1 ]] || return 0
  if ! command -v win32yank.exe >/dev/null 2>&1 && [[ ! -x "$DEST_HOME/.local/bin/win32yank.exe" ]]; then
    local tmp
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/w.zip" https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
    unzip -q "$tmp/w.zip" win32yank.exe -d "$tmp"
    install -m 0755 "$tmp/win32yank.exe" "$DEST_HOME/.local/bin/win32yank.exe"
    rm -f "$tmp/w.zip" "$tmp/win32yank.exe"
    rmdir "$tmp"
  fi
  # Preserve a Windows terminal config if native Windows setup already owns it.
  local winhome
  winhome="$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')" 2>/dev/null || true)"
  if [[ -n "$winhome" && -d "$winhome" && ! -e "$winhome/.wezterm.lua" ]]; then
    cp "$DOTFILES/.config/wezterm/.wezterm.lua" "$winhome/.wezterm.lua"
  fi
}
setup_runtimes() {
  command -v mise >/dev/null || { warn 'mise missing; install packages or use --skip-runtimes'; exit 1; }
  command -v uv >/dev/null || { warn 'uv missing; install packages or use --skip-runtimes'; exit 1; }
  export MISE_CONFIG_DIR="$CONFIG_HOME/mise"
  mise trust "$CONFIG_HOME/mise/config.toml"
  mise --cd "$DEST_HOME" install
  mise --cd "$DEST_HOME" exec -- uv tool install --python 3.14 pgcli
}
main() {
  info "Platform: $OS (WSL=$IS_WSL)"
  if [[ $SKIP_PACKAGES == 0 ]]; then install_brew; else load_brew || true; fi
  link_dotfiles
  if [[ $SKIP_PLUGINS == 0 ]]; then install_zsh_plugins; fi
  if [[ $CONFIG_ONLY == 0 ]]; then install_wsl_helpers; fi
  if [[ $SKIP_RUNTIMES == 0 ]]; then setup_runtimes; fi
  info 'Done. Open a new terminal (zsh or PowerShell 7).'
  # Print the command for the user to run.
  # shellcheck disable=SC2016
  info 'Edit ~/.gitconfig.local for identity/signing. To choose zsh: chsh -s "$(command -v zsh)"'
}
main
