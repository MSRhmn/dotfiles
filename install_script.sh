#!/bin/bash

set -euo pipefail

echo "=== Starting System Setup ==="
sudo apt update


# Core packages
PACKAGES=(
  curl
  vim
  black
  python3-pip
  python3-venv
  tree
  dos2unix
  gnome-tweaks
  gnome-calendar
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
  bat
  ncdu
)

echo "=== Installing Base Packages ==="

for pkg in "${PACKAGES[@]}"; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "$pkg is already installed."
  else
    echo "Installing $pkg..."
    sudo apt install -y "$pkg"
  fi
done


# Helper function to check if command is missing
install_if_missing() {
local cmd="$1"
local pkg="$2"

if ! command -v "$cmd" >/dev/null 2>&1; then
echo "Installing $pkg..."
sudo apt install -y "$pkg"
else
echo "$pkg already installed."
fi
}


# === Install Visual Studio Code ===
if ! command -v code >/dev/null 2>&1; then
echo "Installing VS Code..."

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc |
sudo gpg --dearmor -o /etc/apt/keyrings/vscode.gpg

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/vscode.gpg] https://packages.microsoft.com/repos/code stable main" |
sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt update
sudo apt install -y code
else
echo "VS Code already installed."
fi


# === Install Brave ===
if ! command -v brave-browser >/dev/null 2>&1; then
echo "Installing Brave..."

sudo mkdir -p /usr/share/keyrings

curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
-o /usr/share/keyrings/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" |
sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null

sudo apt update
sudo apt install -y brave-browser
else
echo "Brave already installed."
fi


# === install firefox deb ===
if snap list firefox >/dev/null 2>&1; then
sudo snap remove --purge firefox || true
fi

if ! dpkg -l | grep -qw firefox; then
echo "Installing Firefox (.deb)..."

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg |
sudo tee /etc/apt/keyrings/mozilla.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/mozilla.asc] https://packages.mozilla.org/apt mozilla main" |
sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

sudo apt update
sudo apt install -y firefox
else
echo "Firefox already installed."
fi


# === Install Microsoft Edge ===
if ! command -v microsoft-edge >/dev/null 2>&1; then
  echo "Installing Microsoft Edge..."

  # Import Microsoft GPG key and add Edge repository
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft-edge.gpg > /dev/null

  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | \
    sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null

  sudo apt install -y microsoft-edge-stable
else
  echo "Microsoft Edge is already installed."
fi


# === Install google chrome ===
if ! command -v google-chrome >/dev/null 2>&1; then
read -p "Install Google Chrome? (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
echo "Installing Chrome..."

curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | \
  sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | \
  sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

sudo apt update
sudo apt install -y google-chrome-stable

else
echo "Chrome skipped."
fi
else
echo "Chrome already installed."
fi


# === Install nvm (Node Version Manager) ===
if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
  echo "nvm is already installed."
fi

# Load nvm into current shell
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1090
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js LTS version if not already installed
if ! command -v node >/dev/null 2>&1; then
  echo "Installing Node.js LTS..."
  nvm install --lts
else
  echo "Node.js is already installed."
fi


## === Discord install ===
#TMP_DIR="/tmp/discord-install"  # Temporary directory for download
#DEB_FILE="$TMP_DIR/discord.deb"
#DISCORD_URL="https://discord.com/api/download?platform=linux&format=deb"
#
## Function to check if Discord is installed
#function is_discord_installed {
#    command -v discord >/dev/null 2>&1
#}
#
## Exit if already installed
#if is_discord_installed; then
#    echo "✅ Discord is already installed. Use your update script if needed."
#fi
#
#echo "📥 Downloading Discord..."
#mkdir -p "$TMP_DIR"
#curl -L "$DISCORD_URL" -o "$DEB_FILE"
#
#echo "📦 Installing Discord..."
#sudo apt install -y "$DEB_FILE"
#
#rm -rf "$TMP_DIR"
#
#echo "🎉 Discord installation complete."


# === Install Postman ===
echo "Checking Postman installation..."

if command -v postman &>/dev/null || [ -d "/opt/Postman" ]; then
    echo "Postman is already installed. Skipping..."
else
    echo "Installing Postman..."

    wget https://dl.pstmn.io/download/latest/linux64 -O /tmp/postman.tar.gz

    sudo tar -xzf /tmp/postman.tar.gz -C /opt/
    sudo ln -sf /opt/Postman/Postman /usr/bin/postman

    sudo tee /usr/share/applications/postman.desktop > /dev/null <<EOL
[Desktop Entry]
Name=Postman
Exec=postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Type=Application
Categories=Development;
EOL

    rm /tmp/postman.tar.gz

    echo "Postman installation complete!"
fi


# Clean up unused packages
echo "Running autoremove to clean up..."
sudo apt autoremove -y

echo "=== Script completed successfully ==="
