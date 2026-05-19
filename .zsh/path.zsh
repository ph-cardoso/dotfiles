# ============================================================================
# path.zsh — PATH, Homebrew, pnpm, $BROWSER
# Loaded first so later modules (compinit, tools) see a complete PATH/fpath.
# ============================================================================

# --- ~/.local/bin -----------------------------------------------------------
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# --- Homebrew ---------------------------------------------------------------
# `brew shellenv` output is static for a given prefix, so cache it and only
# regenerate when the brew binary is newer than the cache (big startup win).
() {
  local brew_bin cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/brew-shellenv.zsh"
  case "$OSTYPE" in
    darwin*) brew_bin=/opt/homebrew/bin/brew ;;
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
[[ -x "$HOME/.local/bin/wsl-chrome" ]] && export BROWSER="$HOME/.local/bin/wsl-chrome"
