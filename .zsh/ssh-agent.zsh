# ============================================================================
# ssh-agent.zsh — persistent ssh-agent across shells (WSL has no keychain/
# gnome-keyring wiring a socket in automatically, unlike most desktop distros).
# Agent env is cached like the tool inits in tools.zsh, but keyed on the
# agent's own lifetime rather than a binary's mtime.
# ============================================================================

_ssh_agent_env="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/ssh-agent.env"

[[ -r "$_ssh_agent_env" ]] && source "$_ssh_agent_env" >/dev/null

if ! ssh-add -l &>/dev/null; then
  # A stale socket file can outlive its agent process, so check the PID too.
  if [[ -z "$SSH_AGENT_PID" ]] || ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
    mkdir -p "${_ssh_agent_env:h}"
    # Drop ssh-agent's informational `echo Agent pid …` line — only the
    # SSH_AUTH_SOCK/SSH_AGENT_PID export statements belong in the cache.
    (umask 077; ssh-agent -s | command grep -v '^echo ' >| "$_ssh_agent_env")
    source "$_ssh_agent_env" >/dev/null
  fi
  [[ -f "$HOME/.ssh/github_ed25519" ]] && ssh-add "$HOME/.ssh/github_ed25519" 2>/dev/null
fi

unset _ssh_agent_env