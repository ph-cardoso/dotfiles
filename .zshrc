# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# ~~~~~~~~~~~~~~~ Config Files ~~~~~~~~~~~~~~~~~~~
export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

# ~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=$HISTSIZE

setopt EXTENDED_HISTORY           # Write the history file in the ':start:elapsed;command' format.
setopt HIST_EXPIRE_DUPS_FIRST     # Expire a duplicate event first when trimming history.
setopt HIST_FIND_NO_DUPS          # Do not display a previously found event.
setopt HIST_IGNORE_ALL_DUPS       # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_DUPS           # Do not record an event that was just recorded again.
setopt HIST_IGNORE_SPACE          # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS          # Do not write a duplicate event to the history file.
setopt HIST_REDUCE_BLANKS         # Remove espaços extras
setopt SHARE_HISTORY              # Share history between all sessions.

# ~~~~~~~~~~~~~~~ PATH ~~~~~~~~~~~~~~~~~~~~~~~~
if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# ~~~~~~~~~~~~~~~ homebrew ~~~~~~~~~~~~~~~
case "$OSTYPE" in
  darwin*)
    eval "$(/opt/homebrew/bin/brew shellenv)"
  ;;
  linux*)
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  ;;
esac
export HOMEBREW_NO_ANALYTICS=1

# ~~~~~~~~~~~~~~~ Completions ~~~~~~~~~~~~~~~
fpath+=~/.zfunc
autoload -Uz compinit
if [[ -n "$ZSH_COMPDUMP" ]]; then
  compinit -d "$ZSH_COMPDUMP"
else
  compinit
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

# ~~~~~~~~~~~~~~~ Plugins ~~~~~~~~~~~~~~~~~~~~~~~~
[[ -f ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# ~~~~~~~~~~~~~~~ Sourcing ~~~~~~~~~~~~~~~~~~~~~~~~
source ~/.zsh/aliases.zsh
source ~/.zsh/functions.zsh

# ~~~~~~~~~~~~~~~ Starship Prompt ~~~~~~~~~~~~~~~~~~~~~~~~
eval "$(starship init zsh)"

# ~~~~~~~~~~~~~~~ fzf ~~~~~~~~~~~~~~~~~~~~~~~~
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# source <(fzf --zsh)

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

_fzf_compgen_path() {
  fd --hidden . "$1"
}

_fzf_compgen_dir() {
  fd --type=d --hidden . "$1"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ~~~~~~~~~~~~~~~ zoxide ~~~~~~~~~~~~~~~~~~~~~~~~
eval "$(zoxide init zsh)"
export _ZO_ECHO=1

# ~~~~~~~~~~~~~~~ pyenv ~~~~~~~~~~~~~~~
# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init - zsh)"
# eval "$(pyenv virtualenv-init -)"

# ~~~~~~~~~~~~~~~ nvm ~~~~~~~~~~~~~~~~~~~~~~~~
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ~~~~~~~~~~~~~~~ astral.sh/uv ~~~~~~~~~~~~~~~
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

# ~~~~~~~~~~~~~~~ pnpm ~~~~~~~~~~~~~~~~~~~~~~~~
case "$OSTYPE" in
  darwin*)
    export PNPM_HOME="$HOME/Library/pnpm"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
  ;;
  linux*)
    export PNPM_HOME="$HOME/.local/share/pnpm"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
  ;;
esac
