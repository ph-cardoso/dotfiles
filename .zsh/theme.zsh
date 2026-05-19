# ============================================================================
# theme.zsh — Catppuccin Mocha: single source of truth for shell colors
# Drives fzf, bat, and (as a fallback) eza. The terminal (WezTerm), tmux,
# Starship and Neovim are themed in their own config files to the same palette.
# ============================================================================

# --- Catppuccin Mocha palette (hex, for reference / reuse) ------------------
typeset -gA CATPPUCCIN_MOCHA=(
  rosewater "#f5e0dc"  flamingo "#f2cdcd"  pink     "#f5c2e7"
  mauve     "#cba6f7"  red      "#f38ba8"  maroon   "#eba0ac"
  peach     "#fab387"  yellow   "#f9e2af"  green    "#a6e3a1"
  teal      "#94e2d5"  sky      "#89dceb"  sapphire "#74c7ec"
  blue      "#89b4fa"  lavender "#b4befe"  text     "#cdd6f4"
  subtext1  "#bac2de"  overlay0 "#6c7086"  surface1 "#45475a"
  surface0  "#313244"  base     "#1e1e2e"  mantle   "#181825"
  crust     "#11111b"
)

# --- bat --------------------------------------------------------------------
export BAT_THEME="Catppuccin Mocha"

# --- eza fallback -----------------------------------------------------------
# Primary theming is ~/.config/eza/theme.yml; this only applies if that file
# is absent. Keep it minimal (dirs=blue, symlinks=teal, exec=green).
[[ -f ~/.config/eza/theme.yml ]] || \
  export EZA_COLORS="di=38;2;137;180;250:ln=38;2;148;226;213:ex=38;2;166;227;161"

# --- fzf (official catppuccin/fzf Mocha) ------------------------------------
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--color=border:#6c7086,label:#cdd6f4 \
--multi"

# --- fzf preview helpers (used by fzf's completion engine) ------------------
_fzf_compgen_path() { fd --hidden . "$1"; }
_fzf_compgen_dir()  { fd --type=d --hidden . "$1"; }

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
