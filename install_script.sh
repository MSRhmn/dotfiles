#!/bin/bash

# Update package lists
if ! sudo apt update; then
  echo "Error updating package lists. Exiting."
  exit 1
fi

# Define list of desired software and tools
PACKAGES=(
  curl
  vim
  black
  python3-pip
  python3-venv
  tree
  dos2unix
  gnome-tweaks
  gnome-calendar
  usb-creator-gtk
  fonts-firacode
  ibus-avro
  mpv
  keepassxc
  deja-dup
  libreoffice
  qbittorrent
)

# Install desired software
if ! sudo apt install "${PACKAGES[@]}" -y; then
  echo "Error installing some software. See details with 'apt log'."
  exit 1
fi

# Install nvm (Node Version Manager)
if ! curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then
  echo "Error installing nvm. Exiting."
  exit 1
fi

if ! nvm install --lts; then
  echo "Error installing Node.js LTS version."
  exit 1
fi

# Remove unwanted pre-installed software (assuming Firefox)
if ! sudo snap remove --purge firefox; then
  echo "Error removing Firefox via snap. Continuing..."
fi

# Clean up unused packages
if ! sudo apt autoremove -y; then
  echo "Error during autoremove. Continuing..."
fi

echo "Script completed successfully."

