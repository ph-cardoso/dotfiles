# Catppuccin Mocha, matching Starship, bat, tmux, Neovim and the terminal.
set -g fish_color_normal cdd6f4
set -g fish_color_command 89b4fa
set -g fish_color_param f2cdcd
set -g fish_color_quote a6e3a1
set -g fish_color_redirection f5c2e7
set -g fish_color_end fab387
set -g fish_color_error f38ba8
set -g fish_color_comment 6c7086
set -g fish_color_operator f5c2e7
set -g fish_color_escape eba0ac
set -g fish_color_autosuggestion 6c7086
set -g fish_color_search_match --background=313244
set -g fish_color_selection --background=45475a
set -g fish_pager_color_prefix cba6f7
set -g fish_pager_color_completion cdd6f4
set -g fish_pager_color_description 6c7086
set -g fish_pager_color_selected_background --background=45475a
set -gx BAT_THEME 'Catppuccin Mocha'

set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
set -gx FZF_CTRL_T_COMMAND 'fd --hidden --exclude .git'
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'
set -gx FZF_DEFAULT_OPTS '--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --color=selected-bg:#45475a,border:#6c7086,label:#cdd6f4 --multi'
set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --level=2 --color=always {}'"
