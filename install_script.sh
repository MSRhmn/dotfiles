#!/bin/bash


# Installing Softwares & Tools

sudo apt update -y
sudo apt install git curl vim black python3-pip tree dos2unix gnome-tweaks gnome-clocks fonts-noto-core fonts-firacode ibus-avro mpv keepassxc qbittorrent -y 


# Removing Pre-installed Softwares

sudo snap remove firefox -y
sudo apt remove thunderbird remmina -y
sudo apt autoremove -y

