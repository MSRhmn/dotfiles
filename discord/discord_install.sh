#!/bin/bash

set -e

# Temporary directory for download
TMP_DIR="/tmp/discord-install"
DEB_FILE="$TMP_DIR/discord.deb"
DISCORD_URL="https://discord.com/api/download?platform=linux&format=deb"

# Function to check if Discord is installed
function is_discord_installed {
    command -v discord >/dev/null 2>&1
}

# Exit if already installed
if is_discord_installed; then
    echo "✅ Discord is already installed. Use your update script if needed."
    exit 0
fi

echo "📥 Downloading Discord..."
mkdir -p "$TMP_DIR"
curl -L "$DISCORD_URL" -o "$DEB_FILE"

echo "📦 Installing Discord..."
sudo apt install -y "$DEB_FILE"

rm -rf "$TMP_DIR"

echo "🎉 Discord installation complete."
