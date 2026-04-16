#!/bin/bash

set -euo pipefail

# Define dotfiles directory path
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create ~/bin directory if it doesn't exist
mkdir -p "${HOME}/bin"

# Symlink scripts to user's bin directory
for script in "install_script.sh" "update_script.sh" "suspend.sh"; do
  ln -sf "${DOTFILES_DIR}/${script}" "${HOME}/bin/${script}"
done

# Symlink configuration files to user's home directory
for file in ".bashrc" ".bash_aliases" ".profile" ".gitconfig"; do
  ln -sf "${DOTFILES_DIR}/${file}" "${HOME}/${file}"
done

echo "✅ Symlinks created successfully!"
