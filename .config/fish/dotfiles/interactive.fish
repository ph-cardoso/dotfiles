# Fish already supplies autosuggestions, syntax highlighting and completion.
# Abbreviations expand visibly at the prompt without changing script commands.
abbr -a g git
abbr -a gcm 'git commit -m'
abbr -a gcam 'git commit -a -m'
abbr -a gcad 'git commit -a --amend'
abbr -a c clear
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'
abbr -a rfish 'exec fish'
abbr -a efish '$EDITOR $__fish_config_dir/config.fish'

if command -q eza
    abbr -a ls 'eza --group-directories-first --icons=auto'
    abbr -a ll 'eza -lh --group-directories-first --icons=auto'
    abbr -a la 'eza -lah --group-directories-first --icons=auto'
    abbr -a lsa 'eza -lah --group-directories-first --icons=auto'
    abbr -a lt 'eza --tree --level=2 --long --icons=auto --git'
    abbr -a lta 'eza --tree --level=2 --long --icons=auto --git --all'
end
if command -q bat
    abbr -a cat bat
end

if command -q mise
    mise activate fish | source
end
if command -q zoxide
    zoxide init fish | source
end
if command -q fzf
    fzf --fish | source
end
if test "$TERM" != dumb; and command -q starship
    starship init fish | source
end

# Native macOS clipboard commands remain available; bridge Wayland/WSL.
if command -q win32yank.exe
    alias pbcopy 'win32yank.exe -i'
    alias pbpaste 'win32yank.exe -o'
else if command -q wl-copy
    alias pbcopy wl-copy
    alias pbpaste wl-paste
end
if command -q wsl-clip-img
    abbr -a clipimg wsl-clip-img
end
