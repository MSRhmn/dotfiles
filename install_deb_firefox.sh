#!/bin/bash

# Define Mozilla keyring path
MOZILLA_KEYRING_PATH="/etc/apt/keyrings/packages.mozilla.org.asc"

# Create keyring directory (if it doesn't exist)
if ! sudo mkdir -p "$MOZILLA_KEYRING_PATH"; then
  echo "Error creating directory for keyrings. Exiting."
  exit 1
fi

# Download Mozilla signing key (quietly)
if ! wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O "$MOZILLA_KEYRING_PATH"; then
  echo "Error downloading Mozilla repo signing key. Exiting."
  exit 1
fi

# Add Mozilla repository
echo "deb [signed-by=$MOZILLA_KEYRING_PATH] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

# (Optional) Set pin priority for Mozilla repository
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

# Update package lists and install Firefox (using recommended 'apt' command)
sudo apt update && sudo apt install firefox

