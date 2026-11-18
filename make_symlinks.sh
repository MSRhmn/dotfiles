#!/bin/bash

set -euo pipefail

# Define dotfiles directory path
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${HOME}/.dotfiles-backup"
BACKUP_DIR=""

link_file() {
  local source="$1"
  local target="$2"
  local relative_target

  if [[ -L "$target" && "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
    echo "Already linked: $target"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -z "$BACKUP_DIR" ]]; then
      mkdir -p "$BACKUP_ROOT"
      BACKUP_DIR="$(mktemp -d "${BACKUP_ROOT}/$(date +%Y%m%d-%H%M%S).XXXXXX")"
    fi

    relative_target="${target#"${HOME}"/}"
    mkdir -p "${BACKUP_DIR}/$(dirname "$relative_target")"
    mv -- "$target" "${BACKUP_DIR}/${relative_target}"
    echo "Backed up $target to ${BACKUP_DIR}/${relative_target}"
  fi

  ln -s -- "$source" "$target"
  echo "Linked $target to $source"
}

# Link setup scripts in ~/bin.
mkdir -p "${HOME}/bin"
for script in "install_script.sh" "update_script.sh"; do
  link_file "${DOTFILES_DIR}/${script}" "${HOME}/bin/${script}"
done

# Link configuration files in the home directory.
for file in ".bashrc" ".bash_aliases" ".profile" ".gitconfig"; do
  link_file "${DOTFILES_DIR}/${file}" "${HOME}/${file}"
done

echo "✅ Symlinks created successfully!"
