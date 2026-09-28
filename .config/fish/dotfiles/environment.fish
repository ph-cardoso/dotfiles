set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx STARSHIP_CONFIG "$XDG_CONFIG_HOME/starship.toml"
set -gx BAT_CONFIG_PATH "$XDG_CONFIG_HOME/bat/config"
set -gx EZA_CONFIG_DIR "$XDG_CONFIG_HOME/eza"
set -gx HOMEBREW_NO_ANALYTICS 1

# Homebrew is only needed on platforms without native packages.
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew
    if test -x "$brew_bin"
        "$brew_bin" shellenv fish | source
        break
    end
end

if test (uname) = Darwin
    set -gx PNPM_HOME "$HOME/Library/pnpm"
else
    set -gx PNPM_HOME "$HOME/.local/share/pnpm"
end
# --path avoids writing universal variables on every shell startup.
fish_add_path --path "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/.opencode/bin" "$PNPM_HOME"

# Shims also work before the first prompt and in non-interactive shells.
set -l mise_data "$HOME/.local/share/mise"
if set -q XDG_DATA_HOME
    set mise_data "$XDG_DATA_HOME/mise"
end
if set -q MISE_DATA_DIR
    set mise_data "$MISE_DATA_DIR"
end
fish_add_path --path "$mise_data/shims"

if command -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
end

# Preserve forwarded/keychain agents; reuse the existing desktop service.
if not set -q SSH_AUTH_SOCK; or not test -S "$SSH_AUTH_SOCK"
    if set -q XDG_RUNTIME_DIR
        for agent_socket in "$XDG_RUNTIME_DIR/ssh-agent.socket" "$XDG_RUNTIME_DIR/gcr/ssh" "$XDG_RUNTIME_DIR/keyring/ssh"
            if test -S "$agent_socket"
                set -gx SSH_AUTH_SOCK "$agent_socket"
                break
            end
        end
    end
end

if test -r /proc/sys/kernel/osrelease; and string match -qi '*microsoft*' (command cat /proc/sys/kernel/osrelease)
    if test -x "$HOME/.local/bin/wsl-chrome"
        set -gx BROWSER "$HOME/.local/bin/wsl-chrome"
    end
end
