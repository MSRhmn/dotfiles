#!/bin/bash
set -e  # Exit immediately on error

echo "==== Checking For Updates ===="; echo

# Ensure required tool jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ 'jq' is not installed. Please run: sudo apt install jq"
    exit 1
fi

# Check if Discord is installed
if ! command -v discord &> /dev/null; then
    echo "❌ Discord is not installed. Please run the install script first."
    exit 1
fi

# Get download link and filename
download_link=$(curl -s 'https://discord.com/api/download?platform=linux&format=deb' | grep -E -io 'href="[^\"]+"' | awk -F\" '{print$2}')
download_filename=$(basename "$download_link")

# Extract latest version from filename
latest_version=$(echo "$download_filename" | grep -oP 'discord-\K\d+\.\d+\.\d+(?=\.deb)')

# Find local version
discord_path=$(dirname "$(realpath "$(which discord)")")/resources/build_info.json

# Check if build_info.json exists
if [ ! -f "$discord_path" ]; then
    echo "❌ Could not find build_info.json — cannot determine local version."
    exit 1
fi

# Extract local version
local_version=$(jq -r '.version' "$discord_path")

# Show version info
echo "• Discord latest version is: $latest_version"
echo "• Local Discord version is : $local_version"

# Version comparison
if [[ "$latest_version" == "$local_version" ]]; then
    echo "
*** Discord is already up-to-date ***
"
    exit 0
fi

echo; echo "==== Downloading $download_filename ===="; echo

# Trigger sudo prompt early
sudo -v

echo "• Downloading and installing newer Discord version"
echo "• This may require sudo privileges"

# Download .deb file
wget --trust-server-names "$download_link" &>/dev/null

# Remove current Discord installation
sudo dpkg -r discord &>/dev/null

# Install new version
sudo dpkg -i "$download_filename" &>/dev/null

# Clean up
rm "$download_filename"

echo "
*** Installation Completed ***
"
