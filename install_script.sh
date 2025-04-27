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

# === Install Firefox .deb from Mozilla's APT repo ===

# Remove Firefox Snap version and stub launcher
echo "Ensuring no Firefox Snap or leftover symlinks..."
sudo snap remove --purge firefox >/dev/null 2>&1 || true
sudo rm -f /usr/bin/firefox

# Check if Firefox is installed as a .deb
if ! dpkg -l | grep -q '^ii  firefox '; then
  echo "Installing Firefox from Mozilla APT repo..."

  # Create keyring directory if it doesn't exist
  sudo install -d -m 0755 /etc/apt/keyrings

  # Download Mozilla's signing key
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O - | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

  # Verify key fingerprint
  if gpg --show-keys /etc/apt/keyrings/packages.mozilla.org.asc | grep -q "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"; then
    echo "✔ Firefox key fingerprint verified."
  else
    echo "✖ Firefox key fingerprint verification failed. Exiting for safety."
    exit 1
  fi

  # Add Mozilla APT repo
  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | \
    sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

  # Pin the Mozilla repo high
  echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

  # Update & install
  sudo apt update
  sudo apt install -y firefox
else
  echo "Firefox (.deb) is already installed."
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

# Clean up unused packages
echo "Running autoremove to clean up..."
sudo apt autoremove -y

echo "=== Script completed successfully ==="
