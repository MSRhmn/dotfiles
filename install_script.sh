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

# === Install Firefox (.deb) ===
if command -v snap >/dev/null 2>&1; then
  if snap list firefox >/dev/null 2>&1; then
    sudo snap remove --purge firefox || true
  fi
fi

# Remove previous apt keys
sudo rm -f /etc/apt/keyrings/packages.mozilla.org.gpg

if ! dpkg -l | grep -qw firefox; then
  echo "Installing Firefox (.deb)..."

  sudo install -d -m 0755 /etc/apt/keyrings

  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- |
    sudo gpg --dearmor -o /etc/apt/keyrings/packages.mozilla.org.gpg

  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main" |
    sudo tee /etc/apt/sources.list.d/mozilla.list >/dev/null

  echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla >/dev/null

  sudo apt update
  sudo apt install -y --allow-downgrades firefox

else
  echo "Firefox already installed."
fi

# === Install nvm (Node Version Manager) ===
if [ ! -d "$HOME/.nvm" ] && [ ! -d "$HOME/.config/nvm"]; then
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

  wget https://dl.pstmn.io/download/latest/linux64 -O /tmp/postman.tar.gz

  sudo rm -rf /opt/Postman

  sudo tar -xzf /tmp/postman.tar.gz -C /opt

  sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman

  cat <<EOF | sudo tee /usr/share/applications/postman.desktop >/dev/null
[Desktop Entry]
Name=Postman
Exec=postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Type=Application
Categories=Development;
EOF

  rm -f /tmp/postman.tar.gz

else
  echo "Postman already installed."
fi

# Add Spotify signing key
curl -sS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc |
  sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg

# Add Spotify repository
echo "deb https://repository.spotify.com stable non-free" |
  sudo tee /etc/apt/sources.list.d/spotify.list

sudo apt update
sudo apt install spotify-client

# Clean up unused packages
echo "Running autoremove to clean up..."
sudo apt autoremove -y
sudo apt autoclean -y

echo "=== Script completed successfully ==="
