#!/bin/bash


# Software & Tools

sudo apt update -y
sudo apt install git curl tree dos2unix gnome-tweaks gnome-clocks fonts-noto-core fonts-firacode ibus-avro mpv keepassxc qbittorrent -y 


# Removing pre-installed softwares

sudo snap remove firefox -y
sudo apt remove thunderbird -y
sudo apt autoremove -y

