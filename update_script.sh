#!/bin/bash

set -euo pipefail

echo "=== Starting System Update ==="
sudo apt update

# Verify Mozilla Firefox repository is configured
echo "Checking Firefox repository..."

MOZILLA_SOURCE_CONFIGURED=false
for source_file in \
    /etc/apt/sources.list.d/mozilla.list \
    /etc/apt/sources.list.d/mozilla.sources; do
    if [[ -f "$source_file" ]] && grep -q 'packages.mozilla.org' "$source_file"; then
        MOZILLA_SOURCE_CONFIGURED=true
        break
    fi
done

if [[ "$MOZILLA_SOURCE_CONFIGURED" != true ]]; then
    echo "ERROR: Mozilla Firefox repository is not configured."
    echo "Run the installation script to restore Firefox configuration."
    exit 1
fi

# Upgrade installed packages
echo "Upgrading packages..."
sudo apt upgrade -y

# Ensure Firefox remains installed from Mozilla repository
echo "Ensuring Mozilla Firefox is installed..."
sudo apt install -y firefox
sudo apt-mark manual firefox

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
