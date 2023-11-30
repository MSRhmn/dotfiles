#!/bin/bash


# Symlinking to users bin directory.

ln -sf ~/dotfiles/install_script.sh ~/bin/install_script.sh
ln -sf ~/dotfiles/update_script.sh ~/bin/update_script.sh


# Symlinking to users home directory.

ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.bash_aliases ~/.bash_aliases
ln -sf ~/dotfiles/.profile ~/.profile
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

