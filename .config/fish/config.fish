# Keep environment setup available to scripts, SSH commands and editor tasks.
source "$__fish_config_dir/dotfiles/environment.fish"

if status is-interactive
    set -g fish_greeting
    source "$__fish_config_dir/dotfiles/theme.fish"
    source "$__fish_config_dir/dotfiles/interactive.fish"
end

# Machine-specific settings and secrets never belong in this repository.
if test -f "$__fish_config_dir/config.local.fish"
    source "$__fish_config_dir/config.local.fish"
end
