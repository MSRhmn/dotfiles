#!/bin/bash

# Update package lists
sudo apt update -y

# Install desired softwares and tools
sudo apt install \
  git \
  curl \
  vim \
  black \
  python3-pip \
  python3-venv \
  tree \
  dos2unix \
  gnome-tweaks \
  fonts-firacode \
  ibus-avro \
  mpv \
  keepassxc \
  deja-dup \
  qbittorrent -y

# Install nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Remove unwanted pre-installed softwares
sudo snap remove --purge firefox

# Clean up unused packages
sudo apt autoremove -y
