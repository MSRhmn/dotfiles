#!/bin/bash

# Update package lists
sudo apt update -y

# Install desired softwares and tools
sudo apt install \
  curl \
  vim \
  black \
  python3-pip \
  python3-venv \
  tree \
  dos2unix \
  gnome-tweaks \
  usb-creator-gtk \
  fonts-firacode \
  ibus-avro \
  mpv \
  keepassxc \
  deja-dup \
  libreoffice \
  qbittorrent -y

# Install deb version of Firefox
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
sudo apt-get update && sudo apt-get install firefox

# Install nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install --lts

# Remove unwanted pre-installed softwares
sudo snap remove --purge firefox

# Clean up unused packages
sudo apt autoremove -y
