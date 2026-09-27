# Dotfiles

A Catppuccin Mocha development environment for **Windows, Linux, macOS and
WSL2**. Native Windows uses **PowerShell 7 + WinGet**; Unix uses **zsh +
Homebrew**. The PowerShell profile also works on Linux/macOS when `pwsh` is
installed. Shared configs cover Starship, mise, bat, eza, fd, Neovim and WezTerm.

## Quick start

Clone into a permanent location; shell profiles refer to this checkout.

### Windows

Install Git, PowerShell 7 and App Installer (WinGet), then open **PowerShell 7**:

```powershell
git clone https://github.com/ph-cardoso/dotfiles.git "$HOME/projects/dotfiles"
cd "$HOME/projects/dotfiles"
pwsh -NoProfile -File ./install.ps1
```

The installer prefers per-user WinGet packages. Packages that only provide a
machine installer can display a Windows UAC prompt. It installs the CLI packages
in `windows/packages.json`, deploys configs, and installs the mise runtimes and
pgcli. Existing packages are kept at their installed versions.

Open a **new terminal** after installation to pick up package PATH changes. If
Windows execution policy blocks a local profile, use
`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` when allowed by your
machine policy. The installer does not change execution policy.

To deploy configs without downloading/installing tools:

```powershell
pwsh -NoProfile -File ./install.ps1 -SkipPackages -SkipRuntimes
```

### Linux / macOS / WSL

Start with Git, Bash and curl. Linux also needs Homebrew's build prerequisites
(e.g. `build-essential`, `procps`, `file`, `curl`, `git` on Ubuntu). WSL clipboard
setup additionally uses `unzip`. On macOS, install Xcode Command Line Tools.
See [Homebrew installation requirements](https://docs.brew.sh/Installation).

```bash
git clone https://github.com/ph-cardoso/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
bash install.sh
exec zsh
```

The installer discovers Homebrew on Apple Silicon, Intel macOS and Linux;
installs `Brewfile` packages, links configs, clones the zsh plugins, and installs
runtimes. Failures return a nonzero exit code and can be retried.

```bash
bash install.sh --config-only     # no network, package/runtime/plugin downloads
bash install.sh --skip-packages   # keep installed packages; install everything else
bash install.sh --help
```

`--skip-runtimes` and `--skip-plugins` are also available. Choose zsh as your login
shell with `chsh -s "$(command -v zsh)"` if desired (the shell must be listed in
`/etc/shells`). PowerShell is optional on Unix: install it separately and the
bootstrap configures its all-hosts profile as well.

## Tools and platform differences

| Component | All platforms | Unix / WSL additions |
|---|---|---|
| Runtimes | mise: Node 24, Python 3.14, pnpm 10 | Same versions/config |
| Python tools | uv, uvx, pgcli | Same |
| CLI | rg, fd, eza, bat, fzf, zoxide, fastfetch, gh, jq, tldr | navi, gcc |
| Editor / Git UI | Neovim (LazyVim), lazygit | Same |
| Prompt | Starship, Catppuccin Mocha | Same |
| Docker UI | lazydocker | Same; Docker engine installed separately |
| Multiplexer | WezTerm panes / optional WSL | tmux |

The runtime entries pin release **series**, not exact patch versions. Projects
can override them with their own mise config. pnpm is managed directly by mise;
there is no second Homebrew/Corepack Node installation. Update the declared
series in `.config/mise/config.toml` and rerun the installer.

Install a terminal separately (WezTerm is configured if present). WezTerm uses
bundled JetBrains Mono as a fallback if JetBrainsMono Nerd Font is absent.
Native C/C++ build tools on Windows are optional and must be installed separately
if a project or Neovim plugin needs a compiler. In Neovim run `:Lazy sync` and
`:checkhealth` after first launch; plugins download on first use.

## PowerShell

`.config/powershell/profile.ps1` loads small modules for paths, theme, functions
and PSReadLine. It guards optional tools so an incomplete install still starts.
It uses the actual `$PROFILE.CurrentUserAllHosts` path, including redirected or
OneDrive Documents folders; the same profile applies to console and VS Code.
See [PowerShell profiles](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles).

| Shortcut | Behavior |
|---|---|
| `ll`, `la`, `lt`, `lta` | eza listings and trees |
| `zd`, `z`, `zi` | direct paths / zoxide directory navigation |
| `g`, `gcm`, `gcam`, `gcad` | Git and commit helpers |
| `n`, `ff`, `eff` | Neovim, fuzzy file selection, edit selection |
| `..`, `...`, `....` | parent directories |
| `open`, `path`, `c` | OS opener, PATH listing, clear screen |
| `pbcopy`, `pbpaste`, `clipimg` | Windows text and PNG clipboard helpers |
| `rpwsh`, `epwsh` | reload / edit the profile loader |
| `upd` | WinGet upgrades on Windows; Homebrew upgrades on Unix |
| `Ctrl+R` | fuzzy history |
| `Ctrl+T` / `Ctrl+Alt+F`, `Alt+C` | fuzzy file insertion / change directory |
| `Ctrl+Alt+L`, `Ctrl+Alt+V` | insert a Git commit / variable |
| Tab, Up / Down | menu completion / prefix history search |

PowerShell's `ls`, `cat` and `cd` retain their object-oriented behavior; use `bat`
or `zd` explicitly. `gcm` intentionally replaces the built-in Get-Command alias;
use `Get-Command` by its full name. Keybindings require an interactive console.

Put private machine overrides in `profile.local.ps1` beside the all-hosts
profile. Existing host-specific profiles still execute afterward: remove old
duplicate tool initializers there if needed. The all-hosts profile replaced by
installation is backed up, so custom settings can be moved into the local file.

## Config deployment and local settings

Both installers are safe to rerun. A changed destination is backed up beside the
original as `*.bak.<unique suffix>`; an identical file/link is left alone. Backups
are never overwritten. Restore a backup manually if you want to undo a change.

- **Unix:** symlinks point into this checkout; changes apply immediately.
- **Windows:** tool configs are copied, so no Developer Mode or symlink privilege
  is required. Rerun `install.ps1 -SkipPackages -SkipRuntimes` after editing them.
  The PowerShell loader references the checkout, so profile changes are immediate.
- Shared configs use `$XDG_CONFIG_HOME` (default `~/.config`). Windows also gets
  native Neovim config in `%LOCALAPPDATA%/nvim`, and bat/fd in `%APPDATA%` for use
  outside PowerShell. PowerShell exports the shared tool config paths.
- Git keeps the existing `~/.gitconfig` and adds a portable include. Identity,
  credentials and SSH transport remain intact. Put machine overrides in
  `~/.gitconfig.local`; the example has **no active identity or signing values**.
  Configure signing only after choosing a real key and signer for that machine.
- VS Code settings/extensions remain opt-in reference files under `vscode/`.

Windows uses `~/.config/git/dotfiles` as its deployed portable Git include; Unix
includes the repository's `.gitconfig` directly. Local Git overrides are read
last by the shared file.

## zsh / WSL / terminal

`.zshrc` loads modules in `.zsh/`: paths, completion/history, SSH agent, theme,
cached tool initialization, aliases, functions and fzf widgets. The two zsh
plugins are downloaded into `.zsh/plugins/`; generated files stay untracked.
Desktop/keychain SSH agents are reused. WSL text clipboard uses win32yank and
image clipboard uses `wsl-clip-img`. WSL-only helpers are not installed on native
Linux/macOS; `open` uses the native OS opener there.

WezTerm defaults to **PowerShell 7 on Windows** and **zsh on Unix**. To select a
WSL default, set `DOTFILES_WSL_DISTRO` in the environment used to launch WezTerm,
e.g. `Ubuntu-26.04`. It no longer assumes a particular installed distro. Windows
links prefer Chrome when it exists; other platforms use their system browser.
WSL setup only seeds a Windows WezTerm config if one does not exist, preserving
configuration owned by the native Windows installer.

## Validation and review

```powershell
pwsh -NoProfile -File tests/install.Tests.ps1
```

```bash
bash tests/install.sh
shellcheck install.sh tests/install.sh
```

Tests use temporary destinations: reruns, backups, dangling Unix links, custom
XDG paths, Windows paths with spaces/apostrophes, preserved Git settings, and
PowerShell startup. `.github/workflows/check.yml` runs Windows, Ubuntu and macOS
checks. The test-only `DOTFILES_TARGET_HOME` environment variable selects a Unix
fixture destination; normal installs should leave it unset. Windows tests use
explicit destination parameters.

The cross-platform review addressed the original WSL-only installer, forced WSL
terminal domain, hardcoded username, GNU-only macOS operations, missing Brewfile
dependencies, destructive replacement when a backup already existed, and active
placeholder Git signing. Full package downloads and interactive GUI/editor
behavior are separate from the offline installer tests.
