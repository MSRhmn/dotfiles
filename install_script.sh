#!/bin/bash

# Exit on errors
set -e

echo "=== Updating package lists ==="
if ! sudo apt update; then
  echo "Error updating package lists. Exiting."
  exit 1
fi

# Define list of desired software and tools
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
)

# Install desired software if not already installed
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
  echo "Installing Visual Studio Code..."

  # Install dependencies
  sudo apt install -y wget gpg apt-transport-https

  # Create keyrings directory if missing
  sudo install -d -m 0755 /etc/apt/keyrings

  # Import Microsoft GPG key securely
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null

  # Add the VS Code repository
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
    sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

  # Update and install
  sudo apt update
  sudo apt install -y code

else
  echo "Visual Studio Code is already installed."
fi


# === Install Brave browser ===
if ! command -v brave-browser >/dev/null 2>&1; then
  echo "Installing Brave browser..."

  # Temporarily disable exit-on-error
  set +e

  sudo apt install -y curl gnupg apt-transport-https

  # Create keyring directory if not exists
  sudo mkdir -p /usr/share/keyrings

  # Download and import Brave GPG key (updated URL)
  curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
    -o brave-browser-archive-keyring.gpg

  if [ $? -ne 0 ]; then
    echo "❌ Failed to download Brave key. Skipping Brave installation."
    set -e
    exit 1
  fi

  sudo mv brave-browser-archive-keyring.gpg /usr/share/keyrings/brave-browser-archive-keyring.gpg

  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
    sudo tee /etc/apt/sources.list.d/brave-browser-release.list

  sudo apt update
  sudo apt install -y brave-browser

  # Re-enable exit-on-error
  set -e
else
  echo "Brave browser is already installed."
fi


# === install firefox deb ===

echo "Checking Firefox installation status..."

INSTALL_DEB_FIREFOX=false

# Check if Firefox is installed via .deb (APT)
if dpkg -l | grep -qw firefox; then
  echo "✔ Native (.deb) Firefox is already installed."
else
  echo "❌ Native (.deb) Firefox is not installed."
  INSTALL_DEB_FIREFOX=true
fi

# Check and remove Snap version if found
if snap list firefox >/dev/null 2>&1; then
  echo "⚠ Snap version of Firefox is installed. Removing..."
  sudo snap remove --purge firefox || true
  sudo rm -f /usr/bin/firefox
else
  echo "✔ No Snap version of Firefox detected."
fi

# Install .deb Firefox if not already installed
if [ "$INSTALL_DEB_FIREFOX" = true ]; then
  echo "📦 Installing Firefox from Mozilla's APT repo..."

  # Add Mozilla's repo and key if not already added
  if ! grep -q "packages.mozilla.org" /etc/apt/sources.list.d/mozilla.list 2>/dev/null; then
    echo "Adding Mozilla APT repo..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg | \
      sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | \
      sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

    echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
  fi

  sudo apt update
  if sudo apt install -y firefox; then
    echo "✔ Firefox (.deb) installed successfully."
  else
    echo "❌ Failed to install Firefox."
  fi
fi


# === Install Microsoft Edge ===
if ! command -v microsoft-edge >/dev/null 2>&1; then
  echo "Installing Microsoft Edge..."

  # Import Microsoft GPG key and add Edge repository
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft-edge.gpg > /dev/null

  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | \
    sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null

  sudo apt update
  sudo apt install -y microsoft-edge-stable
else
  echo "Microsoft Edge is already installed."
fi


# === Install Google Chrome ===
if ! command -v google-chrome >/dev/null 2>&1; then
  echo "Installing Google Chrome..."

  # Import Google GPG key and add Chrome repository
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/google-chrome.gpg > /dev/null

  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | \
    sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

  sudo apt update
  sudo apt install -y google-chrome-stable
else
  echo "Google Chrome is already installed."
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


# Discord install
set -e

# Temporary directory for download
TMP_DIR="/tmp/discord-install"
DEB_FILE="$TMP_DIR/discord.deb"
DISCORD_URL="https://discord.com/api/download?platform=linux&format=deb"

# Function to check if Discord is installed
function is_discord_installed {
    command -v discord >/dev/null 2>&1
}

# Exit if already installed
if is_discord_installed; then
    echo "✅ Discord is already installed. Use your update script if needed."
    exit 0
fi

echo "📥 Downloading Discord..."
mkdir -p "$TMP_DIR"
curl -L "$DISCORD_URL" -o "$DEB_FILE"

echo "📦 Installing Discord..."
sudo apt install -y "$DEB_FILE"

rm -rf "$TMP_DIR"

echo "🎉 Discord installation complete."


# Clean up unused packages
echo "Running autoremove to clean up..."
sudo apt autoremove -y

echo "=== Script completed successfully ==="
