# Dotfiles

This repository contains my personal configuration files (dotfiles) for Unix-like systems (macOS and Linux).

## Features
- Bash aliases for Docker, Git, and navigation
- Vim configuration for improved editing experience
- Modular Git configuration with user info and project settings
- Easy installation script (`install.sh`) to set up all dotfiles automatically

## Installation
1. Clone this repository:
   ```sh
   git clone https://github.com/MGalego/dotfiles.git
   cd dotfiles
   ```
2. Run the installer:
   ```sh
   sh install.sh
   ```
   The script will ask for your Git name and email, and set up all configuration files in your home directory.

## Structure
- `dotfiles/.bash_aliases` — Bash aliases
- `dotfiles/.vimrc` — Vim configuration
- `dotfiles/.gitconfig` — Main Git configuration (included from your global config)
- `install.sh` — Installation script

## Usage
After installation, open a new terminal session to use the aliases and configurations.

## License
MIT License. See [License](LICENSE) file for details.
