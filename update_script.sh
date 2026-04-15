#!/bin/bash

# Update the package list and upgrade installed packages
echo "Updating package lists..."
sudo apt update

echo "Upgrading packages..."
sudo apt upgrade -y

# Automatically remove unused packages
echo "Removing unused packages..."
sudo apt autoremove -y

# Clean package cache
echo "Cleaning package cache..."
sudo apt autoclean -y

# # === Discord update script ===
# echo ==== Checking For Updates ====; echo;

# # checking for discord app
# if ! command -v discord &> /dev/null
# then
#    echo Discord could not be found!
#    exit 1
# fi

# if command -v discord >/dev/null 2>&1; then
#   echo "Updating Discord..."

#   TMP_DEB="/tmp/discord.deb"

#   wget -O "$TMP_DEB" "https://discord.com/api/download?platform=linux&format=deb"

#   sudo apt install -y "$TMP_DEB"

#   rm -f "$TMP_DEB"
# else
#   echo "Discord not installed. Skipping."
# fi
