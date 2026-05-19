# fzf ZLE widgets ported from Omarchy (omarchy-zsh/shell/zoptions).
# Sourced from .zshrc AFTER fzf integration and BEFORE
# fast-syntax-highlighting so the new widgets get highlighted.
#
#   Ctrl+Alt+F  insert file/dir path (token-aware)
#   Ctrl+Alt+L  insert commit SHA from git log
#   Ctrl+Alt+V  insert a shell variable name

if command -v fzf &>/dev/null; then
  # Ctrl+Alt+F — file/directory search
  fzf-file-widget() {
    local fd_cmd=$(command -v fdfind || command -v fd || echo "fd")
    local current_token="${LBUFFER##* }"
    local expanded_token=""
    if [[ -n "$current_token" ]]; then
      expanded_token=$(eval echo "$current_token" 2>/dev/null || echo "$current_token")
    fi

    local selected
    if [[ "$expanded_token" == */ ]] && [[ -d "$expanded_token" ]]; then
      selected=$($fd_cmd --color=always --base-directory="$expanded_token" 2>/dev/null | \
        fzf --multi --ansi --prompt="Directory $expanded_token> " \
          --preview="[[ -d $expanded_token{} ]] && ls -lah $expanded_token{} || bat --color=always --style=numbers $expanded_token{} 2>/dev/null || cat $expanded_token{}")
      [[ -n "$selected" ]] && selected="${expanded_token}${selected}"
    else
      selected=$($fd_cmd --color=always 2>/dev/null | \
        fzf --multi --ansi --prompt="Directory> " --query="$expanded_token" \
          --preview="[[ -d {} ]] && ls -lah {} || bat --color=always --style=numbers {} 2>/dev/null || cat {}")
    fi

    if [[ -n "$selected" ]]; then
      selected=$(printf '%q' "$selected")
      LBUFFER="${LBUFFER%$current_token}${selected} "
    fi
    zle reset-prompt
  }
  zle -N fzf-file-widget
  bindkey '^[^F' fzf-file-widget  # Ctrl+Alt+F

  # Ctrl+Alt+L — git log search
  fzf-git-log-widget() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
      echo "Not in a git repository." >&2
      return 1
    fi

    local selected
    selected=$(git log --no-show-signature --color=always \
      --format='%C(bold blue)%h%C(reset) - %C(cyan)%ad%C(reset) %C(yellow)%d%C(reset) %C(normal)%s%C(reset)  %C(dim normal)[%an]%C(reset)' \
      --date=short | \
      fzf --ansi --multi --scheme=history --prompt="Git Log> " \
        --preview='git show --color=always --stat --patch {1}' \
        --preview-window=right:50%:wrap | \
      awk '{print $1}' | \
      xargs -I {} git rev-parse {} 2>/dev/null | \
      tr '\n' ' ')

    if [[ -n "$selected" ]]; then
      LBUFFER="${LBUFFER}${selected}"
    fi
    zle reset-prompt
  }
  zle -N fzf-git-log-widget
  bindkey '^[^L' fzf-git-log-widget  # Ctrl+Alt+L

  # Ctrl+Alt+V — variables search
  fzf-variables-widget() {
    local current_token="${LBUFFER##* }"
    local cleaned_token="${current_token#\$}"

    local selected
    selected=$(typeset -p | awk '{print $1, $2}' | sort -u | awk '{print $2}' | \
      fzf --multi --prompt="Variables> " --preview-window=wrap \
        --preview='echo {} && typeset -p {} 2>/dev/null || echo "No details available"' \
        --query="$cleaned_token")

    if [[ -n "$selected" ]]; then
      if [[ "$current_token" == \$* ]]; then
        selected="\$${selected}"
      fi
      LBUFFER="${LBUFFER%$current_token}${selected} "
    fi
    zle reset-prompt
  }
  zle -N fzf-variables-widget
  bindkey '^[^V' fzf-variables-widget  # Ctrl+Alt+V
fi
