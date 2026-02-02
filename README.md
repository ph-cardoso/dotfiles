# 🚀 Dotfiles

Personal dotfiles repository for configuring my development environment across **macOS** and **Linux** systems. This setup provides a consistent, productive development experience with carefully selected tools and configurations.

## 📋 Table of Contents

- [Overview](#overview)
- [What's Installed](#whats-installed)
- [What's Configured](#whats-configured)
- [Installation](#installation)
- [Directory Structure](#directory-structure)
- [Features](#features)

## 📖 Overview

This repository contains:
- **Shell Configuration**: Zsh with advanced history, plugins, and aliases
- **Package Managers**: Homebrew (macOS/Linux)
- **Version Managers**: NVM (Node.js), uv (Python), pnpm (npm alternative)
- **Terminal Emulators**: Wezterm and Ghostty
- **Editor**: Visual Studio Code with custom settings and extensions
- **Terminal Multiplexer**: Tmux with plugins and custom keybindings
- **CLI Tools**: Modern replacements for standard Unix commands
- **Prompt**: Starship with custom configuration
- **Fuzzy Finder**: fzf with preview capabilities

## 🛠️ What's Installed

### Shell & Package Management
- **Zsh**: Modern shell with extended history and completion system
- **Homebrew**: Package manager for both macOS (`/opt/homebrew/bin/brew`) and Linux (`/home/linuxbrew/.linuxbrew/bin/brew`)

### Version Managers
- **NVM** (`~/.nvm`): Node.js version manager
- **uv** (astral.sh): Fast Python package manager and installer
- **pnpm** (`~/Library/pnpm` on macOS, `~/.local/share/pnpm` on Linux): Fast, space-efficient npm client

### Terminal & Editors
- **Wezterm**: GPU-accelerated terminal emulator with Lua configuration
- **Ghostty**: High-performance terminal emulator (config in `.config/ghostty`)
- **Visual Studio Code**: Code editor with 31+ extensions and custom settings

### Terminal Tools
- **Starship**: Cross-platform shell prompt (config: `.config/starship.toml`)
- **Tmux**: Terminal multiplexer with plugins (config: `.config/tmux/tmux.conf`)
- **fzf**: Fuzzy finder for command-line navigation and file selection
- **zoxide**: Smart directory navigation (`cd` replacement with `z` command)

### CLI Tools (Modern Replacements)
- **ripgrep** (`rg`): Fast grep alternative
- **fd**: User-friendly find alternative
- **eza**: Modern ls replacement with git integration
- **bat**: cat clone with syntax highlighting
- **fast-syntax-highlighting**: Zsh syntax highlighting plugin
- **zsh-autosuggestions**: Zsh autocompletion suggestions

## ⚙️ What's Configured

### Shell Configuration (`.zshrc`)

#### History Management
- **100,000 entries** stored in `~/.zsh_history`
- Extended history format with timestamps
- Duplicate deduplication and smart history sharing across sessions
- Ignores entries starting with spaces (sensitive commands)

#### Path & Package Managers
- `~/.local/bin` added to PATH
- Homebrew environment initialization (platform-specific)
- Completion cache location: `~/.cache/zsh/zcompdump`

#### Plugins
- **zsh-autosuggestions**: Smart command suggestions based on history
- **fast-syntax-highlighting**: Real-time syntax highlighting while typing

#### Prompt
- **Starship**: Custom prompt with git status, language versions, and more

#### Fuzzy Finder (`fzf`)
- Integration with `fd` for better file discovery
- Catppuccin Mocha color theme
- File and directory preview using `eza` and `bat`
- Custom completion functions for `cd`, `export`, `unset`, and `ssh`

#### Version Manager Integrations
- **NVM**: Node.js version management
- **uv**: Python shell completions
- **uvx**: Standalone Python scripts with shell completion
- **pnpm**: Platform-specific PATH configuration

#### Other Tools
- **zoxide**: Smart cd with directory memory

### Zsh Modules (`.zsh/`)

#### Aliases (`.zsh/aliases.zsh`)
```zsh
rzsh      # Reload .zshrc
ezsh      # Edit .zshrc with code
grep → rg    # Use ripgrep instead of grep
find → fd    # Use fd instead of find
ls → eza     # Use eza with git and icon support
cat → bat    # Use bat with syntax highlighting
neofetch → fastfetch  # Lightweight system info display
c         # Clear screen alias
```

#### Functions (`.zsh/functions.zsh`)
- `path()`: Display PATH in readable format
- `check_clip()`: Windows clipboard support fallback (WSL compatibility)

### Visual Studio Code (`vscode/`)

#### Settings (`vscode/settings.json`)
- **Theme**: Min Dark with Fluent Icons
- **Font**: JetBrains Mono (14pt) with ligatures enabled
- **Editor**: Minimap disabled, semantic highlighting disabled for performance
- **Terminal**: JetBrainsMono Nerd Font with ligatures
- **Formatting**: Auto-format on save for JSON, Python, TypeScript
- **Telemetry**: Completely disabled
- **Extensions**: Recommended extensions list in `extensions.json`

#### Extensions (`vscode/extensions.json`)
Includes 31 extensions for:
- Python development (Pylance, Ruff formatter, Python indent)
- Web development (ESLint, Prettier, Tailwind CSS)
- Git integration (GitLens)
- AI coding (GitHub Copilot, Copilot Chat)
- Infrastructure (YAML, TOML, Jinja)
- Productivity (Better Comments, Color Highlight, Markdown tools)

### Wezterm (`.config/wezterm/.wezterm.lua`)
- **Theme**: Catppuccin Mocha
- **Font**: JetBrainsMono Nerd Font (12pt)
- **Opacity**: 85% window transparency
- **WSL Default**: Ubuntu-24.04 domain
- **Window**: 70% of screen size, centered, no tab bar

### Tmux (`.config/tmux/tmux.conf`)
- **Prefix**: `Ctrl-a` (not `Ctrl-b`)
- **Plugins**:
  - `vim-tmux-navigator`: Navigate panes with Ctrl-hjkl
  - `tmux-resurrect`: Persist sessions after restart
  - `tmux-continuum`: Auto-save sessions every 15 minutes
  - `tmux2k`: Status bar theme with Catppuccin colors
- **Features**:
  - Mouse support enabled
  - 50,000-line scrollback buffer
  - Automatic window renumbering
  - Pane base index starts at 1
  - Quick window navigation with Ctrl-p/Ctrl-n

### Starship (`.config/starship.toml`)
- Custom prompt format with git, language versions, and command status
- Catppuccin Mocha color scheme
- Optimized for performance

### Bat, fd, Ghostty Configs
- `.config/bat/`: Syntax highlighting preferences
- `.config/fd/`: File search configuration
- `.config/ghostty/`: Terminal emulator settings

## 🚀 Installation

### macOS
```bash
# Clone the repository
git clone https://github.com/ph-cardoso/dotfiles.git ~/.dotfiles

# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install zsh starship fzf fd ripgrep bat eza zoxide nvm tmux wezterm

# Create symlinks (or manually copy files to ~)
# Copy .zshrc to ~/
# Copy .zsh/ directory to ~/
# Copy .config/ directory to ~/
# Copy bin/ directory to ~/.local/bin/

# Source the new shell configuration
source ~/.zshrc
```

### Linux (including WSL)
```bash
# Clone the repository
git clone https://github.com/ph-cardoso/dotfiles.git ~/.dotfiles

# Install Linuxbrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install zsh starship fzf fd ripgrep bat eza zoxide nvm tmux wezterm

# Create symlinks (or manually copy files to ~)
# Copy .zshrc to ~/
# Copy .zsh/ directory to ~/
# Copy .config/ directory to ~/
# Copy bin/ directory to ~/.local/bin/

# Change default shell to Zsh
chsh -s /bin/zsh

# Source the new shell configuration
source ~/.zshrc
```

### Additional Setup

#### Install Zsh Plugins
```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions

# fast-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.zsh/plugins/fast-syntax-highlighting
```

#### Install Tmux Plugin Manager (tpm)
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Load plugins in Tmux
tmux source-file ~/.config/tmux/tmux.conf
# Press Ctrl-a + I (capital i) to install plugins
```

#### Install VS Code Extensions
```bash
code --install-extension miguelsolorio.fluent-icons
code --install-extension github.copilot
# ... or use the extensions.json file for batch installation
```

#### Python Setup (uv)
```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create Python symlinks
~/.local/bin/uv-python-symlink.sh
```

## 📁 Directory Structure

```
dotfiles/
├── README.md                    # This file
├── .zshrc                       # Main shell configuration
├── .zsh/
│   ├── aliases.zsh             # Shell aliases
│   ├── functions.zsh           # Custom shell functions
│   └── plugins/                # Zsh plugins directory
├── .config/
│   ├── starship.toml           # Starship prompt config
│   ├── bat/                    # bat (cat) config
│   ├── fd/                     # fd config
│   ├── ghostty/                # Ghostty terminal config
│   ├── tmux/
│   │   └── tmux.conf           # Tmux configuration
│   └── wezterm/
│       └── .wezterm.lua        # Wezterm configuration
├── vscode/
│   ├── settings.json           # VS Code settings
│   └── extensions.json         # Recommended extensions
└── bin/
    └── uv-python-symlink.sh    # Python symlink script
```

## ✨ Features

### Cross-Platform Compatibility
- ✅ Detects OS (macOS/Linux) and applies appropriate configurations
- ✅ Homebrew paths configured for both platforms
- ✅ pnpm paths platform-specific
- ✅ WSL Windows support (Wezterm default domain)

### Performance Optimized
- Fast shell startup with lazy loading
- Completion cache system
- Efficient history management
- Modern tools replacing slow legacy commands

### Developer Friendly
- Git integration across shell and editor
- Multiple version managers for language support
- Syntax highlighting and autocompletion
- Fuzzy finding for efficient navigation
- Terminal multiplexing with Tmux

### Customizable
- Modular configuration files
- Easy to extend and modify
- Modern, well-documented settings
- Compatible with latest tool versions

## 📝 Notes

- This configuration assumes Homebrew is installed
- Some tools may require additional setup (e.g., NVM, uv)
- VS Code extensions are recommendations; install only what you need
- Tmux plugins are automatically managed by tpm
- Check individual tool documentation for advanced customization

## 🔗 References

- [Zsh Documentation](https://www.zsh.org/)
- [Starship](https://starship.rs/)
- [Homebrew](https://brew.sh/)
- [Tmux](https://github.com/tmux/tmux)
- [Wezterm](https://wezfurlong.org/wezterm/)
- [fzf](https://github.com/junegunn/fzf)
- [uv](https://astral.sh/uv/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd](https://github.com/sharkdp/fd)
- [eza](https://github.com/eza-community/eza)
- [bat](https://github.com/sharkdp/bat)

---

**Last Updated**: 2026-02-02
