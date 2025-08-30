#!/bin/bash
set -e

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
PROJECT_GITCONFIG="$(pwd)/dotfiles/.gitconfig"
echo "Configuring $GITCONFIG..."
cat <<EOF > "$GITCONFIG"
[user]
    name = $git_name
    email = $git_email

[include]
    path = $PROJECT_GITCONFIG
EOF

# Add source for aliases in ~/.bashrc if not present
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ]; then
    if ! grep -Fxq "source ~/.bash_aliases" "$BASHRC"; then
        echo "source ~/.bash_aliases" >> "$BASHRC"
        echo "Added 'source ~/.bash_aliases' to ~/.bashrc"
    fi
else
    echo "source ~/.bash_aliases" > "$BASHRC"
    echo "Created ~/.bashrc with 'source ~/.bash_aliases'"
fi

# Reload aliases in the current session
if [ -f "$HOME/.bash_aliases" ]; then
    echo "Reloading aliases in bash/zsh..."
    source "$HOME/.bash_aliases"
fi

echo "Dotfiles installed and configured."