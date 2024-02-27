#!/bin/bash


# Install Softwares & Tools

sudo apt update -y
sudo apt install git curl vim black python3-pip python3-venv tree dos2unix gnome-tweaks gnome-clocks fonts-noto-core fonts-firacode ibus-avro mpv keepassxc qbittorrent -y 

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash


# Remove Pre-installed Softwares

sudo snap remove firefox -y
sudo apt remove thunderbird remmina cheese -y
sudo apt autoremove -y

