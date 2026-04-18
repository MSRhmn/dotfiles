#!/usr/bin/env bash

# Navigation
alias ...="cd ../.."
alias ....="cd ../../.."

alias d="cd ~/Dropbox"
alias se="cd ~/Dropbox/software_engineering"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias p="cd ~/projects"

alias ll="ls -alF"

# Applications
alias python=python3
alias du1="du -h --max-depth=1" # Disk usage shortcut
alias nc="ncdu"
alias rm="rm -i" # Safer remove of files

# Tool Fixes

# 'fd' Ubuntu installs as 'fdfind'
if command -v fdfind >/dev/null 2>&1; then
  alias fd="fdfind"
fi

# 'bat' Ubuntu installs as 'batcat'
if command -v batcat >/dev/null 2>&1; then
  alias bat="batcat"
fi

# Shell script formatter
alias fmtsh="shfmt -i 2 -ci -w"
