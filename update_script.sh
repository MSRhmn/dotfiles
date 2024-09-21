#!/bin/bash

# Update the package list and upgrade installed packages
sudo apt update && sudo apt upgrade -y

# Automatically remove unused packages
sudo apt autoremove -y
