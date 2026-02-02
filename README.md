# Dotfiles

This repository contains configuration files and scripts for personal dotfiles, providing a customized development environment across different operating systems.

## Installation

### Windows
1. Open PowerShell.
2. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/ph-cardoso/dotfiles.git
   ```
3. Run the installation script:
   ```bash
   ./dotfiles/install.ps1
   ```

### macOS
1. Open Terminal.
2. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/ph-cardoso/dotfiles.git
   ```
3. Run the installation script:
   ```bash
   sh dotfiles/install.sh
   ```

### Linux
1. Open your terminal.
2. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/ph-cardoso/dotfiles.git
   ```
3. Run the installation script:
   ```bash
   bash dotfiles/install.sh
   ```

## Configuration
After installation, you may want to customize the configurations:

- Update specific configuration files located in `~/.config/` (or appropriate locations based on your system).
- Feel free to modify `.bashrc`, `.vimrc`, etc., to suit your preferences.

## Usage
To make use of the configurations, restart your terminal, or run the following command:
```bash
source ~/.bashrc  # or the appropriate file for your shell
```

## License
This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.