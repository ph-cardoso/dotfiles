# ============================================================================
# tools.zsh — third-party tool initialisation (guarded + cached)
# Each tool's init/completion output is deterministic per binary version, so
# cache it and regenerate only when the binary is newer than the cache. This
# avoids spawning starship/zoxide/mise/uv/fzf on every single shell startup.
# ============================================================================

# _cached_init <cache-name> <binary> <command…>
#   Sources <command> output, cached at ~/.cache/zsh/init-<name>.zsh.
_cached_init() {
  local name="$1" bin="$2"; shift 2
  command -v "$bin" >/dev/null 2>&1 || return 0
  local binpath="${commands[$bin]}"
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init-${name}.zsh"
  if [[ ! -s "$cache" || -z "$binpath" || "$binpath" -nt "$cache" ]]; then
    mkdir -p "${cache:h}"
    "$@" >| "$cache" 2>/dev/null
  fi
  source "$cache"
}

# Prompt
_cached_init starship starship starship init zsh

# Smart cd (z / zi); zd wrapper + `cd` alias live in functions.zsh/aliases.zsh
_cached_init zoxide zoxide zoxide init zsh
export _ZO_ECHO=1

# Polyglot runtime manager
_cached_init mise mise mise activate zsh

# uv / uvx shell completions
_cached_init uv  uv  uv  generate-shell-completion zsh
_cached_init uvx uvx uvx --generate-shell-completion zsh

# fzf key-bindings (Ctrl-R/Ctrl-T/Alt-C) + completion
_cached_init fzf fzf fzf --zsh
