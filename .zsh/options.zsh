# ============================================================================
# options.zsh — keybindings, history, completion system, shell options
# Loaded after path.zsh so compinit sees Homebrew's site-functions on fpath.
# ============================================================================

# Emacs keybindings even if $EDITOR is vi
bindkey -e

# --- History ----------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY        # ':start:elapsed;command' format
setopt HIST_EXPIRE_DUPS_FIRST  # trim duplicates first
setopt HIST_FIND_NO_DUPS       # don't show a previously found event
setopt HIST_IGNORE_ALL_DUPS    # drop older duplicate on new dupe
setopt HIST_IGNORE_DUPS        # don't record an immediately-repeated event
setopt HIST_IGNORE_SPACE       # don't record space-prefixed commands
setopt HIST_SAVE_NO_DUPS       # don't write duplicates to the file
setopt HIST_REDUCE_BLANKS      # trim superfluous blanks
setopt SHARE_HISTORY           # share history across sessions

# --- Shell options ----------------------------------------------------------
# Disable command hashing so mise version switches resolve immediately.
setopt NO_HASH_CMDS
setopt NO_HASH_DIRS

# --- Completion system (performance-cached) ---------------------------------
# compinit's fpath security scan is the single biggest startup cost. Cache the
# dump and skip the scan (-C) when it is < 24h old; do a full rebuild + scan
# otherwise. Then byte-compile the dump so sourcing it is fast.
export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${ZSH_COMPDUMP:h}"
fpath+=~/.zfunc
autoload -Uz compinit
if [[ -n "$ZSH_COMPDUMP"(#qN.mh-24) ]]; then
  compinit -C -d "$ZSH_COMPDUMP"
else
  compinit -d "$ZSH_COMPDUMP"
fi
if [[ -s "$ZSH_COMPDUMP" && ( ! -s "$ZSH_COMPDUMP.zwc" || "$ZSH_COMPDUMP" -nt "$ZSH_COMPDUMP.zwc" ) ]]; then
  zcompile "$ZSH_COMPDUMP"
fi

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# --- Menu / history keybindings --------------------------------------------
# complist provides the `menuselect` keymap (highlighted interactive menu).
zmodload zsh/complist
bindkey '^[[Z' reverse-menu-complete            # Shift-Tab cycles backwards
bindkey -M menuselect '^[[Z' reverse-menu-complete

# Up/Down: prefix history search (Ctrl-R stays full fuzzy via fzf).
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
bindkey "^[OA" history-search-backward
bindkey "^[OB" history-search-forward
