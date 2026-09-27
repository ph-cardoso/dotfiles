#!/usr/bin/env bash
# Offline integration test; never writes to the real home or installs packages.
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
fixture="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-test.XXXXXX")"
trap 'rm -rf "$fixture"' EXIT
target="$fixture/home with spaces"
export DOTFILES_TARGET_HOME="$target"
export XDG_CONFIG_HOME="$target/custom config"
mkdir -p "$target"
printf 'original zshrc\n' > "$target/.zshrc"
printf '[user]\n name = Existing User\n[core]\n sshCommand = custom-ssh\n' > "$target/.gitconfig"
bash "$repo/install.sh" --config-only
[[ -L "$target/.zshrc" && -L "$XDG_CONFIG_HOME/mise" && -L "$target/.wezterm.lua" ]]
[[ -L "$XDG_CONFIG_HOME/powershell/profile.ps1" ]]
[[ "$(git config --file "$target/.gitconfig" --get user.name)" == 'Existing User' ]]
[[ "$(git config --file "$target/.gitconfig" --get core.sshCommand)" == 'custom-ssh' ]]
count="$(find "$target" -name '*.bak.*' | wc -l | tr -d ' ')"
bash "$repo/install.sh" --config-only
[[ "$(find "$target" -name '*.bak.*' | wc -l | tr -d ' ')" == "$count" ]]
# Simulate replacing a managed symlink with a new personal file.
rm "$target/.zshrc"
printf 'newer zshrc\n' > "$target/.zshrc"
bash "$repo/install.sh" --config-only
grep -l 'original zshrc' "$target"/.zshrc.bak.* >/dev/null
grep -l 'newer zshrc' "$target"/.zshrc.bak.* >/dev/null
# Replacing a dangling link must preserve that link too.
rm "$target/.wezterm.lua"
ln -s "$fixture/missing" "$target/.wezterm.lua"
bash "$repo/install.sh" --config-only
[[ -L "$target/.wezterm.lua" ]]
if bash "$repo/install.sh" --not-an-option >/dev/null 2>&1; then exit 1; fi
for file in "$repo/install.sh" "$repo/tests/install.sh" "$repo"/bin/*; do bash -n "$file"; done
if command -v zsh >/dev/null; then
  for file in "$repo/.zshrc" "$repo"/.zsh/*.zsh; do zsh -n "$file"; done
fi
printf 'PASS: Unix links, XDG paths, reruns, backups, Git preservation and shell syntax\n'
