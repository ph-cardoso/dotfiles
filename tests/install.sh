#!/usr/bin/env bash
# Offline integration test; never writes to the real home or installs packages.
# Fish snippets use single quotes so Fish, not Bash, expands their variables.
# shellcheck disable=SC2016
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
for args in '--shell bash' '--shell' '--package-manager apt' '--package-manager'; do
  # Intentional word splitting tests the command-line argument parser.
  # shellcheck disable=SC2086
  if bash "$repo/install.sh" $args >/dev/null 2>&1; then exit 1; fi
done

# Switching shells preserves the other shell, Fish state and personal functions.
mkdir -p "$XDG_CONFIG_HOME/fish/functions"
printf '# local fish config\n' > "$XDG_CONFIG_HOME/fish/config.fish"
if command -v fish >/dev/null; then
  fish -c 'set -U dotfiles_fixture retained'
else
  printf '# retained state\n' > "$XDG_CONFIG_HOME/fish/fish_variables"
fi
printf 'function personal; end\n' > "$XDG_CONFIG_HOME/fish/functions/personal.fish"
printf 'set -gx DOTFILES_LOCAL_LOADED yes\n' > "$XDG_CONFIG_HOME/fish/config.local.fish"
bash "$repo/install.sh" --shell fish --config-only
[[ -L "$XDG_CONFIG_HOME/fish/config.fish" && -L "$XDG_CONFIG_HOME/fish/functions/n.fish" ]]
[[ -L "$target/.zshrc" ]]
grep -q retained "$XDG_CONFIG_HOME/fish/fish_variables"
grep -q personal "$XDG_CONFIG_HOME/fish/functions/personal.fish"
count="$(find "$target" -name '*.bak.*' | wc -l | tr -d ' ')"
bash "$repo/install.sh" --shell fish --config-only
[[ "$(find "$target" -name '*.bak.*' | wc -l | tr -d ' ')" == "$count" ]]
bash "$repo/install.sh" --shell zsh --config-only
[[ -L "$XDG_CONFIG_HOME/fish/config.fish" ]]

# Exercise backend dispatch without network access or package installation.
mkdir -p "$fixture/bin"
cat > "$fixture/bin/paru" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$DOTFILES_PACKAGE_LOG"
SH
cat > "$fixture/bin/git" <<'SH'
#!/usr/bin/env bash
if [[ ${1:-} == clone ]]; then echo 'Unexpected plugin download for Fish' >&2; exit 99; fi
exec "$DOTFILES_REAL_GIT" "$@"
SH
chmod +x "$fixture/bin/paru" "$fixture/bin/git"
if [[ $(uname -s) == Linux ]]; then
  export DOTFILES_REAL_GIT
  DOTFILES_REAL_GIT="$(command -v git)"
  DOTFILES_PACKAGE_LOG="$fixture/packages" PATH="$fixture/bin:$PATH" \
    bash "$repo/install.sh" --shell fish --package-manager paru --skip-runtimes
  grep -qx -- '-Syu' "$fixture/packages"
  grep -qx fish "$fixture/packages"
  grep -qx mise "$fixture/packages"
  if grep -qx zsh "$fixture/packages"; then exit 1; fi
fi

for file in "$repo/install.sh" "$repo/tests/install.sh" "$repo"/bin/*; do bash -n "$file"; done
if command -v zsh >/dev/null; then
  for file in "$repo/.zshrc" "$repo"/.zsh/*.zsh; do zsh -n "$file"; done
fi
if command -v fish >/dev/null; then
  for file in "$repo"/.config/fish/config.fish "$repo"/.config/fish/{dotfiles,functions,conf.d}/*.fish; do fish --no-config -n "$file"; done
  export XDG_CACHE_HOME="$fixture/cache" XDG_DATA_HOME="$fixture/data"
  # Startup must be quiet and load local overrides, including in scripts.
  output="$(fish -c 'printf "%s" $DOTFILES_LOCAL_LOADED' 2>"$fixture/fish-stderr")"
  if [[ -s "$fixture/fish-stderr" ]]; then cat "$fixture/fish-stderr" >&2; exit 1; fi
  [[ "$output" == yes && ! -s "$fixture/fish-stderr" ]]
  TERM=xterm-256color fish -i -c 'abbr --query g; and functions --query n zd eff; and test "$dotfiles_fixture" = retained'
  # Filenames with spaces and newlines must reach the editor as separate args.
  cat > "$fixture/bin/nvim" <<'SH'
#!/usr/bin/env bash
printf '%s\0' "$@" > "$DOTFILES_EDITOR_LOG"
SH
  chmod +x "$fixture/bin/nvim"
  DOTFILES_EDITOR_LOG="$fixture/editor" DOTFILES_MOCK_BIN="$fixture/bin" fish -c '
    set -gx PATH $DOTFILES_MOCK_BIN $PATH
    function ff; printf "%s\0" "file with spaces" "file
with newline"; end
    eff
  '
  printf 'file with spaces\0file\nwith newline\0' > "$fixture/expected"
  cmp "$fixture/editor" "$fixture/expected"
  # Direct directory navigation works even without zoxide initialization.
  DOTFILES_TEST_DIR="$target" fish -c 'zd "$DOTFILES_TEST_DIR"; and test "$PWD" = "$DOTFILES_TEST_DIR"'
fi
printf 'PASS: shell choice, package dispatch, Fish startup/helpers, backups, Git preservation and syntax\n'
