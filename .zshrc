# ============================================================================
# .zshrc — thin loader. Real config lives in ~/.zsh/*.zsh, sourced in order.
#
#   path      PATH / Homebrew / pnpm / $BROWSER   (first: sets fpath)
#   options   keybindings / history / completion  (compinit, perf-cached)
#   theme     Catppuccin Mocha (fzf/bat/eza)
#   plugins   zsh-autosuggestions                 (before tools/widgets)
#   tools     starship / zoxide / mise / uv / fzf (cached inits)
#   aliases   command aliases
#   functions shell functions (zd, open, clipboard, …)
#   widgets   custom fzf ZLE widgets (Ctrl+Alt+F/L/V)
#   fsh       fast-syntax-highlighting            (MUST be last)
# ============================================================================

ZDOTDIR_MODULES=~/.zsh

source "$ZDOTDIR_MODULES/path.zsh"
source "$ZDOTDIR_MODULES/options.zsh"
source "$ZDOTDIR_MODULES/theme.zsh"

# zsh-autosuggestions: gray inline history suggestion (accept with → / End).
[[ -f $ZDOTDIR_MODULES/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source "$ZDOTDIR_MODULES/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

source "$ZDOTDIR_MODULES/tools.zsh"
source "$ZDOTDIR_MODULES/aliases.zsh"
source "$ZDOTDIR_MODULES/functions.zsh"

# Custom fzf ZLE widgets — after fzf init (tools.zsh), before highlighting.
[[ -f $ZDOTDIR_MODULES/fzf-widgets.zsh ]] && source "$ZDOTDIR_MODULES/fzf-widgets.zsh"

# fast-syntax-highlighting MUST be sourced last so it wraps every ZLE widget
# defined above (fzf + custom widgets).
[[ -f $ZDOTDIR_MODULES/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && \
  source "$ZDOTDIR_MODULES/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
