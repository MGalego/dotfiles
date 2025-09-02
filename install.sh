#!/bin/bash
set -e

OS=$(uname -s)
case "$OS" in
    Linux*)
        if grep -q Microsoft /proc/version 2>/dev/null; then
            PLATFORM="WSL"
        else
            PLATFORM="Linux"
        fi
        ;;
    Darwin*)
        PLATFORM="macOS"
        ;;
    *)
        PLATFORM="Unknown"
        ;;
esac

echo "Detected platform: $PLATFORM"

read -p "Enter your name for Git: " git_name
read -p "Enter your email for Git: " git_email

# Function to merge or copy dotfile
merge_or_copy() {
    src="$1"    
    dest="$2"
    if [ -f "$dest" ]; then
        echo "Updating $dest..."
        while IFS= read -r line; do
            grep -Fxq "$line" "$dest" || echo "$line" >> "$dest"
        done < "$src"
    else
        echo "Creating $dest..."
        cp "$src" "$dest"
    fi
}

merge_or_copy "$(pwd)/dotfiles/.bash_aliases" "$HOME/.bash_aliases"

merge_or_copy "$(pwd)/dotfiles/.vimrc" "$HOME/.vimrc"

# Configure .gitconfig
GITCONFIG="$HOME/.gitconfig"
# Get absolute path that works across platforms
if [ "$PLATFORM" = "WSL" ]; then
    # In WSL, ensure we use the correct path format
    PROJECT_GITCONFIG="$(realpath "$(pwd)/dotfiles/.gitconfig")"
else
    PROJECT_GITCONFIG="$(pwd)/dotfiles/.gitconfig"
fi

echo "Configuring $GITCONFIG..."
cat <<EOF > "$GITCONFIG"
[user]
    name = $git_name
    email = $git_email

[include]
    path = $PROJECT_GITCONFIG
EOF

# Add source for aliases in shell config files
add_alias_source() {
    local config_file="$1"
    local alias_line="source ~/.bash_aliases"
    
    if [ -f "$config_file" ]; then
        if ! grep -Fxq "$alias_line" "$config_file"; then
            echo "$alias_line" >> "$config_file"
            echo "Added '$alias_line' to $config_file"
        else
            echo "Alias source already exists in $config_file"
        fi
    else
        echo "$alias_line" > "$config_file"
        echo "Created $config_file with '$alias_line'"
    fi
}

# Configure shell based on platform and available shells
# Different OS have different default shells and terminal configurations
if [ "$PLATFORM" = "macOS" ]; then
    # macOS: Default shell is zsh (since macOS Catalina), but also support bash
    add_alias_source "$HOME/.zshrc"    # Primary for macOS
    add_alias_source "$HOME/.bashrc"   # For users who switched to bash
    add_alias_source "$HOME/.profile"  # Fallback for any POSIX shell
elif [ "$PLATFORM" = "WSL" ]; then
    # WSL: Default shell is usually bash, but users may install zsh
    add_alias_source "$HOME/.bashrc"   # Primary for WSL
    add_alias_source "$HOME/.profile"  # Fallback for any POSIX shell
    add_alias_source "$HOME/.zshrc"    # For users who installed zsh
else
    # Linux: Default shell varies by distribution (bash, dash, zsh)
    add_alias_source "$HOME/.bashrc"   # Most common on Linux
    add_alias_source "$HOME/.profile"  # Universal fallback
    add_alias_source "$HOME/.zshrc"    # For users who use zsh
fi

# Reload aliases in the current session
if [ -f "$HOME/.bash_aliases" ]; then
    echo "Reloading aliases in current session..."
    # Detect current shell and source aliases accordingly
    current_shell=$(ps -p $$ -o comm= 2>/dev/null | sed 's/^-//')
    case "$current_shell" in
        *zsh*)
            source "$HOME/.bash_aliases" 2>/dev/null || echo "Note: Restart terminal to use aliases"
            ;;
        *bash*)
            source "$HOME/.bash_aliases" 2>/dev/null || echo "Note: Restart terminal to use aliases"
            ;;
        *sh*)
            # For POSIX sh, try to source but it might not work with all alias syntax
            . "$HOME/.bash_aliases" 2>/dev/null || echo "Note: Restart terminal to use aliases"
            ;;
        *)
            echo "Note: Restart terminal to use aliases (unknown shell: $current_shell)"
            ;;
    esac
fi

echo "Dotfiles installed and configured successfully!"
echo "Platform: $PLATFORM"
echo "Current shell: $(ps -p $$ -o comm= 2>/dev/null | sed 's/^-//' || echo 'unknown')"
echo "To use the new configuration, either:"
case "$PLATFORM" in
    "macOS")
        echo "  - Restart your terminal, or"
        echo "  - Run: source ~/.zshrc (default) or source ~/.bashrc (if using bash)"
        ;;
    "WSL")
        echo "  - Restart your terminal, or"
        echo "  - Run: source ~/.bashrc (default) or source ~/.zshrc (if using zsh)"
        ;;
    *)
        echo "  - Restart your terminal, or"
        echo "  - Run: source ~/.bashrc (most common) or source ~/.zshrc (if using zsh)"
        ;;
esac