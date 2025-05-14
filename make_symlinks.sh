#!/bin/bash

# Define dotfiles directory path
DOTFILES_DIR="${HOME}/dotfiles"

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

# Handle potential errors
if [[ $? -ne 0 ]]; then
  echo "❌ Error occurred during symlinking process."
  exit 1
fi

echo "✅ Symlinks created successfully!"
