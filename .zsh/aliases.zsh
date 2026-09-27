# ~~~~~~~~~~~~~~~ Shell mgmt ~~~~~~~~~~~~~~~
alias rzsh="source ~/.zshrc && echo '~/.zshrc reloaded!'"
alias ezsh="zed ~/.zshrc"
alias c="clear"
# upd is platform-aware (functions.zsh).

# ~~~~~~~~~~~~~~~ Modern CLI replacements ~~~~~~~~~~~~~~~
alias grep="rg"  # https://github.com/BurntSushi/ripgrep
alias find="fd"  # https://github.com/sharkdp/fd
alias cat="bat"  # https://github.com/sharkdp/bat
alias neofetch="fastfetch -c neofetch.jsonc"  # https://github.com/fastfetch-cli/fastfetch

# ~~~~~~~~~~~~~~~ Listing (eza) ~~~~~~~~~~~~~~~
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'

# ~~~~~~~~~~~~~~~ Directories ~~~~~~~~~~~~~~~
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
# zoxide-powered cd (zd defined in functions.zsh)
command -v zoxide &>/dev/null && alias cd="zd"

# ~~~~~~~~~~~~~~~ Git ~~~~~~~~~~~~~~~
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# ~~~~~~~~~~~~~~~ Tools ~~~~~~~~~~~~~~~
alias t='tmux attach || tmux new -s Work'
alias eff='$EDITOR "$(ff)"'
# Save Windows-clipboard image to a PNG and print its path (paste into agents)
command -v wsl-clip-img &>/dev/null && alias clipimg='wsl-clip-img'
