#!/usr/bin/env bash
# ============================================================================
# dotfiles installer — idempotent, safe to re-run.
#
#   git clone git@github.com:ph-cardoso/dotfiles.git ~/Personal/dotfiles
#   ~/Personal/dotfiles/install.sh
#
# Symlinks the $HOME-mirror config into place, installs Homebrew packages from
# the Brewfile, and bootstraps WSL-specific helpers. Existing real files are
# backed up to <file>.bak once.
# ============================================================================
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

# --- pretty logging ---------------------------------------------------------
c_blue=$'\e[1;34m'; c_green=$'\e[1;32m'; c_yellow=$'\e[1;33m'; c_reset=$'\e[0m'
info() { printf '%s==>%s %s\n' "$c_blue"  "$c_reset" "$*"; }
ok()   { printf '%s  ✓%s %s\n' "$c_green" "$c_reset" "$*"; }
warn() { printf '%s  !%s %s\n' "$c_yellow" "$c_reset" "$*"; }

# --- platform detection -----------------------------------------------------
OS="unknown"; IS_WSL=0
case "$OSTYPE" in
  darwin*) OS="macos" ;;
  linux*)  OS="linux"
           grep -qiE 'microsoft|wsl' /proc/sys/kernel/osrelease 2>/dev/null && IS_WSL=1 ;;
esac
info "Platform: $OS$([[ $IS_WSL == 1 ]] && echo ' (WSL)')"

# --- symlink helper ---------------------------------------------------------
# link <repo-relative-src> <abs-dest>
link() {
  local src="$DOTFILES/$1" dest="$2"
  [[ -e "$src" ]] || { warn "missing in repo: $1 (skipped)"; return 0; }
  if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
    ok "linked: $dest"; return 0
  fi
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ ! -e "$dest.bak" ]]; then
      mv "$dest" "$dest.bak"; warn "backed up existing $dest -> $dest.bak"
    else
      rm -rf "$dest"
    fi
  fi
  ln -sfn "$src" "$dest"
  ok "linked: $dest -> $src"
}

# --- Homebrew + Brewfile ----------------------------------------------------
install_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [[ "$OS" == "macos" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"
  else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null || true)"
  fi
  info "brew bundle"
  brew bundle --file="$DOTFILES/Brewfile"
  ok "Homebrew packages installed"
}

# --- dotfile symlinks -------------------------------------------------------
link_dotfiles() {
  info "Linking dotfiles"
  link .zshrc                   "$HOME/.zshrc"
  link .zsh                     "$HOME/.zsh"
  link .gitconfig               "$HOME/.gitconfig"
  link .config/tmux             "$HOME/.config/tmux"
  link .config/bat              "$HOME/.config/bat"
  link .config/eza              "$HOME/.config/eza"
  link .config/mise             "$HOME/.config/mise"
  link .config/nvim             "$HOME/.config/nvim"
  link .config/starship.toml    "$HOME/.config/starship.toml"
  link .config/fd               "$HOME/.config/fd"
  mkdir -p "$HOME/.local/bin"
  local f
  for f in "$DOTFILES"/bin/*; do
    [[ -e "$f" ]] || continue
    link "bin/$(basename "$f")" "$HOME/.local/bin/$(basename "$f")"
  done
}

# --- git local include ------------------------------------------------------
setup_gitconfig_local() {
  if [[ ! -e "$HOME/.gitconfig.local" ]]; then
    cp "$DOTFILES/.gitconfig.local.example" "$HOME/.gitconfig.local"
    warn "Created ~/.gitconfig.local from example — edit it with your identity"
  else
    ok "~/.gitconfig.local present"
  fi
}

# --- zsh plugins ------------------------------------------------------------
install_zsh_plugins() {
  local pdir="$DOTFILES/.zsh/plugins"
  mkdir -p "$pdir"
  [[ -d "$pdir/zsh-autosuggestions" ]] || {
    info "Cloning zsh-autosuggestions"
    git clone -q --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
      "$pdir/zsh-autosuggestions"; }
  [[ -d "$pdir/fast-syntax-highlighting" ]] || {
    info "Cloning fast-syntax-highlighting"
    git clone -q --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting \
      "$pdir/fast-syntax-highlighting"; }
  ok "zsh plugins present"
}

# --- WSL: win32yank ---------------------------------------------------------
install_win32yank() {
  [[ $IS_WSL == 1 ]] || return 0
  command -v win32yank.exe >/dev/null 2>&1 && { ok "win32yank present"; return 0; }
  [[ -x "$HOME/.local/bin/win32yank.exe" ]] && { ok "win32yank present"; return 0; }
  info "Downloading win32yank.exe"
  local tmp; tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/w.zip" \
    https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
  python3 -c "import zipfile;zipfile.ZipFile('$tmp/w.zip').extract('win32yank.exe','$tmp')"
  install -m 0755 "$tmp/win32yank.exe" "$HOME/.local/bin/win32yank.exe"
  rm -rf "$tmp"
  ok "win32yank installed"
}

# --- WSL: WezTerm config to Windows %USERPROFILE% ---------------------------
# Cross-/mnt/c symlinks are unreliable, so copy. Re-run install.sh after
# editing .config/wezterm/.wezterm.lua.
install_wezterm() {
  [[ $IS_WSL == 1 ]] || return 0
  local winhome
  winhome="$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')" 2>/dev/null || true)"
  [[ -n "$winhome" && -d "$winhome" ]] || { warn "Could not resolve Windows %USERPROFILE%"; return 0; }
  cp "$DOTFILES/.config/wezterm/.wezterm.lua" "$winhome/.wezterm.lua"
  ok "WezTerm config copied to $winhome/.wezterm.lua"
}

# --- runtimes ---------------------------------------------------------------
setup_mise() {
  command -v mise >/dev/null 2>&1 || { warn "mise not found (Brewfile installs it)"; return 0; }
  info "mise install"
  mise install || warn "mise install reported issues (continuing)"
  ok "mise runtimes ready"
}

main() {
  install_brew
  link_dotfiles
  setup_gitconfig_local
  install_zsh_plugins
  install_win32yank
  install_wezterm
  setup_mise
  echo
  ok "Done. Open a new shell, or: exec zsh"
  command -v zsh >/dev/null && [[ "${SHELL:-}" != *zsh ]] && \
    warn "Set zsh as default shell:  chsh -s \"\$(command -v zsh)\""
}

main "$@"
