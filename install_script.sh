#!/bin/bash

set -euo pipefail

echo "=== Starting System Setup ==="
sudo apt update

# Core packages
DESKTOP_ENV=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')

PACKAGES=(
  ca-certificates
  gnupg
  apt-transport-https
  curl
  vim
  shfmt
  black
  python3-pip
  python3-venv
  tree
  dos2unix
  usb-creator-gtk
  fonts-firacode
  fonts-lohit-beng-bengali
  ibus-avro
  mpv
  vlc
  keepassxc
  deja-dup
  libreoffice
  qbittorrent
  wget
  tmux
  htop
  ripgrep
  fd-find
  fzf
  mediainfo
  bat
  ncdu
  zip
  unzip
)

if [[ "$DESKTOP_ENV" == *gnome* ]]; then
  PACKAGES+=(
    gnome-tweaks
    gnome-calendar
  )
fi

echo "=== Installing Base Packages ==="

for pkg in "${PACKAGES[@]}"; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "$pkg is already installed."
  else
    echo "Installing $pkg..."
    sudo apt install -y "$pkg"
  fi
done

# === Install Visual Studio Code ===
if ! command -v code >/dev/null 2>&1; then
  echo "Installing VS Code..."

  sudo mkdir -p /etc/apt/keyrings

  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc |
    sudo gpg --dearmor -o /etc/apt/keyrings/vscode.gpg

  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/vscode.gpg] https://packages.microsoft.com/repos/code stable main" |
    sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

  sudo apt update
  sudo apt install -y code
else
  echo "VS Code already installed."
fi

# === Install Brave ===
if ! command -v brave-browser >/dev/null 2>&1; then
  echo "=== Installing Brave Browser ==="

  sudo mkdir -p /etc/apt/keyrings

  curl -fsSLo /tmp/brave.key https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

  sudo mv /tmp/brave.key /etc/apt/keyrings/brave-browser.gpg
  sudo chmod 644 /etc/apt/keyrings/brave-browser.gpg

  echo "deb [signed-by=/etc/apt/keyrings/brave-browser.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" |
    sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null

  sudo apt update
  sudo apt install -y brave-browser
else
  echo "Brave already installed."
fi

# === Install Firefox from Mozilla APT Repository ===

# Use Mozilla's current key format and configure its repository before
# removing the Snap. Pin Ubuntu's transitional package to prevent APT from
# reinstalling Firefox as a Snap.
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- |
  sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null
sudo chmod 644 /etc/apt/keyrings/packages.mozilla.org.asc

. /etc/os-release
if dpkg --compare-versions "$VERSION_ID" ge 26.04; then
  sudo rm -f /etc/apt/sources.list.d/mozilla.list
  cat <<EOF | sudo tee /etc/apt/sources.list.d/mozilla.sources >/dev/null
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
else
  sudo rm -f /etc/apt/sources.list.d/mozilla.sources
  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" |
    sudo tee /etc/apt/sources.list.d/mozilla.list >/dev/null
fi

cat <<EOF | sudo tee /etc/apt/preferences.d/mozilla >/dev/null
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000

Package: firefox
Pin: release o=Ubuntu
Pin-Priority: -1
EOF

sudo apt update

# Remove Firefox Snap only after the APT pin and Mozilla package are available.
if command -v snap >/dev/null 2>&1 && snap list firefox >/dev/null 2>&1; then
  sudo snap remove --purge firefox
fi

# Install Firefox from Mozilla repository
sudo apt install -y firefox

# Prevent accidental removal by autoremove
sudo apt-mark manual firefox

echo "=== Mozilla Firefox installation verified ==="

# === Install nvm (Node Version Manager) ===
if [ ! -d "$HOME/.nvm" ] && [ ! -d "$HOME/.config/nvm" ]; then
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
  echo "nvm is already installed."
fi

# Load nvm into current shell
if [ -d "$HOME/.config/nvm" ]; then
  export NVM_DIR="$HOME/.config/nvm"
else
  export NVM_DIR="$HOME/.nvm"
fi

# shellcheck disable=SC1090
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js LTS version if not already installed
if ! command -v node >/dev/null 2>&1; then
  echo "Installing Node.js LTS..."
  nvm install --lts
else
  echo "Node.js is already installed."
fi

# === Install Postman ===
if ! command -v postman >/dev/null 2>&1; then

  echo "=== Installing Postman ==="

  POSTMAN_TMP_DIR=$(mktemp -d)
  if ! wget -q https://dl.pstmn.io/download/latest/linux64 -O "$POSTMAN_TMP_DIR/postman.tar.gz"; then
    rm -rf -- "$POSTMAN_TMP_DIR"
    echo "Postman download failed; existing installation was left untouched." >&2
    exit 1
  fi

  POSTMAN_STAGE_DIR=$(sudo mktemp -d /opt/.postman-install.XXXXXX)
  if ! sudo tar -xzf "$POSTMAN_TMP_DIR/postman.tar.gz" -C "$POSTMAN_STAGE_DIR" ||
    ! sudo test -x "$POSTMAN_STAGE_DIR/Postman/Postman"; then
    sudo rm -rf -- "$POSTMAN_STAGE_DIR"
    rm -rf -- "$POSTMAN_TMP_DIR"
    echo "Postman archive is invalid; existing installation was left untouched." >&2
    exit 1
  fi

  POSTMAN_BACKUP_DIR=$(sudo mktemp -d /opt/.postman-backup.XXXXXX)
  POSTMAN_HAD_PREVIOUS=0
  if sudo test -e /opt/Postman; then
    if ! sudo mv -- /opt/Postman "$POSTMAN_BACKUP_DIR/Postman"; then
      sudo rm -rf -- "$POSTMAN_STAGE_DIR" "$POSTMAN_BACKUP_DIR"
      rm -rf -- "$POSTMAN_TMP_DIR"
      echo "Could not prepare the existing Postman installation; nothing was replaced." >&2
      exit 1
    fi
    POSTMAN_HAD_PREVIOUS=1
  fi

  if ! sudo mv -- "$POSTMAN_STAGE_DIR/Postman" /opt/Postman; then
    if [[ "$POSTMAN_HAD_PREVIOUS" == "1" ]] &&
      ! sudo mv -- "$POSTMAN_BACKUP_DIR/Postman" /opt/Postman; then
      sudo rm -rf -- "$POSTMAN_STAGE_DIR"
      rm -rf -- "$POSTMAN_TMP_DIR"
      echo "Postman update failed; the old installation remains at $POSTMAN_BACKUP_DIR/Postman." >&2
      exit 1
    fi
    sudo rm -rf -- "$POSTMAN_STAGE_DIR" "$POSTMAN_BACKUP_DIR"
    rm -rf -- "$POSTMAN_TMP_DIR"
    echo "Could not install Postman; cleanup is complete." >&2
    exit 1
  fi

  sudo rm -rf -- "$POSTMAN_STAGE_DIR" "$POSTMAN_BACKUP_DIR"
  rm -rf -- "$POSTMAN_TMP_DIR"

  sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman

  cat <<EOF | sudo tee /usr/share/applications/postman.desktop >/dev/null
[Desktop Entry]
Name=Postman
Exec=postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Type=Application
Categories=Development;
EOF

else
  echo "Postman already installed."
fi

# Spotify's Linux client is optional and may not support every Ubuntu release.
# Opt in explicitly with INSTALL_SPOTIFY=1 when running this script.
if [[ "${INSTALL_SPOTIFY:-0}" == "1" ]]; then
  if dpkg-query -W -f='${Status}' spotify-client 2>/dev/null | grep -q 'install ok installed'; then
    echo "Spotify is already installed."
  else
    echo "=== Installing Spotify (optional) ==="
    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc |
      sudo gpg --dearmor --yes -o /etc/apt/keyrings/spotify.gpg
    sudo chmod 644 /etc/apt/keyrings/spotify.gpg
    echo "deb [signed-by=/etc/apt/keyrings/spotify.gpg] https://repository.spotify.com stable non-free" |
      sudo tee /etc/apt/sources.list.d/spotify.list >/dev/null

    if sudo apt update && sudo apt install -y spotify-client; then
      echo "Spotify installed."
    else
      echo "Spotify could not be installed for this Ubuntu release; continuing setup."
    fi
  fi
else
  echo "Skipping optional Spotify installation. Set INSTALL_SPOTIFY=1 to opt in."
fi

# Clean up unused packages
echo "Running autoremove to clean up..."
sudo apt autoremove -y
sudo apt autoclean -y

echo "=== Script completed successfully ==="
