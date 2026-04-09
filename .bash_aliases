#!/usr/bin/env bash

# Navigation
alias ...="cd ../.."
alias ....="cd ../../.."

alias d="cd ~/Dropbox"
alias se="cd ~/Dropbox/software_engineering"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias p="cd ~/projects"


# Applications
alias python=python3


# Tool Fixes

# 'fd' Ubuntu installs as 'fdfind'
if command -v fdfind >/dev/null 2>&1; then
alias fd="fdfind"
fi

