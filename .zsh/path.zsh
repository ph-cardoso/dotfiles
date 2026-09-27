# ============================================================================
# path.zsh — PATH, Homebrew, pnpm, $BROWSER
# Loaded first so later modules (compinit, tools) see a complete PATH/fpath.
# ============================================================================

# --- User tools -------------------------------------------------------------
typeset -U path
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"
export BAT_CONFIG_PATH="$XDG_CONFIG_HOME/bat/config"
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# --- Homebrew ---------------------------------------------------------------
# `brew shellenv` output is static for a given prefix, so cache it and only
# regenerate when the brew binary is newer than the cache (big startup win).
() {
  local brew_bin cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/brew-shellenv.zsh"
  case "$OSTYPE" in
    darwin*)
      if [[ -x /opt/homebrew/bin/brew ]]; then brew_bin=/opt/homebrew/bin/brew
      else brew_bin=/usr/local/bin/brew; fi ;;
    linux*)  brew_bin=/home/linuxbrew/.linuxbrew/bin/brew ;;
  esac
  if [[ -x "$brew_bin" ]]; then
    if [[ ! -s "$cache" || "$brew_bin" -nt "$cache" ]]; then
      mkdir -p "${cache:h}"
      "$brew_bin" shellenv >| "$cache"
    fi
    source "$cache"
  fi
}
export HOMEBREW_NO_ANALYTICS=1

# --- pnpm -------------------------------------------------------------------
case "$OSTYPE" in
  darwin*) export PNPM_HOME="$HOME/Library/pnpm" ;;
  linux*)  export PNPM_HOME="$HOME/.local/share/pnpm" ;;
esac
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# --- Browser (WSL → Chrome) -------------------------------------------------
# CLI tools that honour $BROWSER (gh, npm, etc.) open links in Windows Chrome.
if [[ -r /proc/sys/kernel/osrelease ]] && command grep -qiE 'microsoft|wsl' /proc/sys/kernel/osrelease; then
  [[ -x "$HOME/.local/bin/wsl-chrome" ]] && export BROWSER="$HOME/.local/bin/wsl-chrome"
fi
command -v nvim &>/dev/null && export EDITOR=nvim VISUAL=nvim
