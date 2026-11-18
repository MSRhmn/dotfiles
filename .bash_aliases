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

# Google Drive mount and unmount with rclone
mountdrive() {
  local mount_dir="$HOME/GoogleDrive"

  if ! command -v rclone >/dev/null 2>&1; then
    echo "mountdrive: install rclone first." >&2
    return 127
  fi

  mkdir -p -- "$mount_dir" || return

  if mountpoint -q "$mount_dir"; then
    echo "Google Drive is already mounted at $mount_dir."
    return 0
  fi

  rclone mount gdrive: "$mount_dir" \
    --vfs-cache-mode full \
    --dir-cache-time 24h \
    --tpslimit 10 \
    --daemon
}

unmountdrive() {
  local mount_dir="$HOME/GoogleDrive"

  if ! mountpoint -q "$mount_dir"; then
    echo "unmountdrive: Google Drive is not mounted at $mount_dir." >&2
    return 1
  fi

  if command -v fusermount3 >/dev/null 2>&1; then
    fusermount3 -u "$mount_dir"
  elif command -v fusermount >/dev/null 2>&1; then
    fusermount -u "$mount_dir"
  else
    echo "unmountdrive: install fuse3 or fuse to unmount the drive." >&2
    return 127
  fi
}
