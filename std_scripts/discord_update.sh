#!/bin/bash
set -e # Exit immediately on error

# === Discord update script ===
echo ==== Checking For Updates ====
echo

# checking for discord app
if ! command -v discord &>/dev/null; then
  echo Discord could not be found!
  exit 1
fi

if command -v discord >/dev/null 2>&1; then
  echo "Updating Discord..."

  TMP_DEB="/tmp/discord.deb"

  wget -O "$TMP_DEB" "https://discord.com/api/download?platform=linux&format=deb"

  sudo apt install -y "$TMP_DEB"

  rm -f "$TMP_DEB"
else
  echo "Discord not installed. Skipping."
fi
