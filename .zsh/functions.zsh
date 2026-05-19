# Show path in a readable way
path(){
  echo $PATH | tr ':' '\n'
}

# ~~~~~~~~~~~~~~~ Clipboard (WSL) ~~~~~~~~~~~~~~~
# Prefer win32yank for bidirectional Windows clipboard; fall back to clip.exe
# (copy only) if win32yank isn't installed yet.
if command -v win32yank.exe &>/dev/null; then
  alias clip='win32yank.exe -i'
  alias pbcopy='win32yank.exe -i'
  alias pbpaste='win32yank.exe -o'
elif ! command -v clip &>/dev/null && command -v clip.exe &>/dev/null; then
  alias clip='clip.exe'
fi

# ~~~~~~~~~~~~~~~ zoxide-powered cd ~~~~~~~~~~~~~~~
if command -v zoxide &>/dev/null; then
  zd() {
    if (( $# == 0 )); then
      builtin cd ~ || return
    elif [[ -d $1 ]]; then
      builtin cd "$1" || return
    else
      if ! z "$@"; then
        echo "Error: Directory not found"
        return 1
      fi
      printf "\U000F17A9 "
      pwd
    fi
  }
fi

# ~~~~~~~~~~~~~~~ Editor / nvim ~~~~~~~~~~~~~~~
n() { if [ "$#" -eq 0 ]; then command nvim . ; else command nvim "$@"; fi; }

# ~~~~~~~~~~~~~~~ fzf helpers ~~~~~~~~~~~~~~~
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ff="fzf --preview 'case \$(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac'"
else
  alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
fi

# scp a recently-modified file picked via fzf to a destination
sff() {
  if [ $# -eq 0 ]; then echo "Usage: sff <destination> (e.g. sff host:/tmp/)"; return 1; fi
  local file
  file=$(command find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | ff) \
    && [ -n "$file" ] && scp "$file" "$1"
}

# ~~~~~~~~~~~~~~~ open (WSL-aware) ~~~~~~~~~~~~~~~
# http(s) links → Windows Chrome; local files/dirs → Windows Explorer.
# (xdg-open is mostly a no-op under WSL.)
open() (
  case "$1" in
    http://*|https://*)
      if [[ -x "$HOME/.local/bin/wsl-chrome" ]]; then
        "$HOME/.local/bin/wsl-chrome" "$@" >/dev/null 2>&1 &
      else
        explorer.exe "$@" >/dev/null 2>&1 &
      fi
      ;;
    *)
      if command -v explorer.exe &>/dev/null; then
        explorer.exe "$@" >/dev/null 2>&1 &
      else
        xdg-open "$@" >/dev/null 2>&1 &
      fi
      ;;
  esac
)
