# Dotfiles

Personal development environment for **WSL2 (Ubuntu) under Windows**, themed
end-to-end with **Catppuccin Mocha**. One script replicates it on a new machine.

The repository is a **`$HOME` mirror**: paths here map directly under `$HOME`
(plus `bin/` → `~/.local/bin/`). `install.sh` symlinks them into place.

## Quick start

```bash
git clone git@github.com:ph-cardoso/dotfiles.git ~/Personal/dotfiles
~/Personal/dotfiles/install.sh
exec zsh
```

`install.sh` is idempotent (safe to re-run). It:

1. Installs Homebrew if missing and runs `brew bundle` against the `Brewfile`.
2. Symlinks the `$HOME`-mirror config into place (existing real files backed
   up once to `*.bak`).
3. Creates `~/.gitconfig.local` from the example (edit it with your identity).
4. Clones the zsh plugins into `.zsh/plugins/`.
5. **WSL:** downloads `win32yank.exe` and copies the WezTerm config to the
   Windows `%USERPROFILE%`.
6. Runs `mise install` for language runtimes.

Then set zsh as the default shell: `chsh -s "$(command -v zsh)"`.

## What's inside

### Shell — zsh (`.zshrc` + `.zsh/`)

`.zshrc` is a thin loader; real config is split into commented modules:

| Module | Responsibility |
|---|---|
| `.zsh/path.zsh` | PATH, cached Homebrew `shellenv`, pnpm, `$BROWSER` |
| `.zsh/options.zsh` | history, completion (perf-cached `compinit` + `zcompile`), keybindings |
| `.zsh/theme.zsh` | Catppuccin Mocha palette → fzf / bat / eza |
| `.zsh/tools.zsh` | cached inits: starship, zoxide, mise, uv/uvx, fzf |
| `.zsh/aliases.zsh` | aliases (eza `ls`, `cd`→`zd`, git, …) |
| `.zsh/functions.zsh` | `zd`, WSL-aware `open()`, clipboard helpers |
| `.zsh/fzf-widgets.zsh` | `Ctrl+Alt+F/L/V` fzf ZLE widgets |

Tool init output is cached under `~/.cache/zsh/` and regenerated only when the
binary changes — keeps startup ~0.3s.

### Tooling (Homebrew — see `Brewfile`)

- **Runtimes:** `mise` (node, python — pinned in `.config/mise/config.toml`),
  `uv`, `pnpm`
- **CLI:** ripgrep, fd, eza, bat, zoxide, fzf, fastfetch, gh, lazygit,
  lazydocker, neovim, tmux
- **Prompt:** Starship — minimal layout, Catppuccin Mocha palette
  (`.config/starship.toml`)

### Theme — Catppuccin Mocha everywhere

WezTerm, tmux, fzf, bat, eza, Starship and Neovim/LazyVim all use Mocha. The
palette lives once in `.zsh/theme.zsh`; each tool's own config matches it.

### Editor — Neovim / LazyVim (`.config/nvim/`)

LazyVim with the `catppuccin` (mocha) colorscheme. `lazy-lock.json` is
committed for reproducible plugin versions; plugin clones are not vendored.

### Terminal — WezTerm (`.config/wezterm/.wezterm.lua`)

Catppuccin Mocha, JetBrainsMono Nerd Font, WSL default domain. Ctrl+click on a
link opens **Google Chrome** (overrides the Windows default browser) via an
`open-uri` handler. Because the live file lives on the Windows side, the
installer **copies** it to `%USERPROFILE%\.wezterm.lua` — re-run `install.sh`
after editing it.

### tmux (`.config/tmux/tmux.conf`)

Hand-rolled, plugin-free, Catppuccin Mocha. Prefix `Ctrl-Space` (secondary
`Ctrl-b`), vi copy mode, Alt-based pane/window navigation, OSC52 clipboard.

### Git (`.gitconfig` + `~/.gitconfig.local`)

`.gitconfig` holds portable settings (rebase pull, autoSetupRemote, histogram
diff, rerere, aliases) and `[include]`s `~/.gitconfig.local` for
machine-specific identity and 1Password SSH commit signing. The local file is
**gitignored**; start from `.gitconfig.local.example`.

### WSL clipboard

- **Text:** `win32yank.exe` bridges the Windows clipboard (zsh `clip`/
  `pbcopy`/`pbpaste`, Neovim `+`/`*` registers).
- **Images:** `bin/wsl-clip-img` saves the Windows clipboard image to a PNG and
  prints its path (alias `clipimg`) — for pasting screenshots into coding
  agents.

## Directory structure

```
dotfiles/
├── install.sh                 # idempotent bootstrap
├── Brewfile                   # Homebrew bundle (brew bundle dump)
├── .gitconfig                 # portable git config
├── .gitconfig.local.example   # template → ~/.gitconfig.local (gitignored)
├── .zshrc                     # thin loader
├── .zsh/                      # zsh modules + plugins/ (bootstrapped)
├── .config/
│   ├── starship.toml          # minimal Catppuccin Mocha prompt
│   ├── bat/ eza/ fd/ mise/    # CLI tool configs
│   ├── tmux/tmux.conf
│   ├── wezterm/.wezterm.lua   # copied to Windows %USERPROFILE%
│   └── nvim/                  # LazyVim config + lazy-lock.json
├── bin/                       # → ~/.local/bin (wsl-chrome, wsl-clip-img, …)
└── vscode/                    # VS Code settings + recommended extensions
```

## Replicating on a new machine

1. Install [WSL2 + Ubuntu](https://learn.microsoft.com/windows/wsl/install) and
   [WezTerm](https://wezfurlong.org/wezterm/) on Windows.
2. `git clone` this repo and run `install.sh`.
3. Edit `~/.gitconfig.local` (identity + your 1Password signing path).
4. `exec zsh`; in Neovim run `:Lazy sync`.

To refresh the Homebrew list after installing new tools:
`brew bundle dump --force --describe --file=~/Personal/dotfiles/Brewfile`.
