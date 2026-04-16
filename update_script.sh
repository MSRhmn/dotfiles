#!/bin/bash

set -euo pipefail

# Update the package list and upgrade installed packages
echo "=== Starting System Update ==="
sudo apt update

echo "Upgrading packages..."
sudo apt upgrade -y

# Automatically remove unused packages
echo "Removing unused packages..."
sudo apt autoremove -y

# Clean package cache
echo "Cleaning package cache..."
sudo apt autoclean -y

# Update Node.js (nvm)
if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"

  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  echo "Updating Node.js (LTS)..."
  nvm install --lts >/dev/null
fi

echo "=== System Update Completed Successfully ==="
