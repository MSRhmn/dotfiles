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

# === Install Brave browser ===
if ! command -v brave-browser >/dev/null 2>&1; then
  echo "Installing Brave browser..."
  sudo apt install -y curl gnupg apt-transport-https
  curl -fsSL https://brave.com/signing-key.asc | sudo gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
    sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
  sudo apt install -y brave-browser
else
  echo "Brave browser is already installed."
fi

# === Remove Firefox Snap version if present ===
if snap list firefox >/dev/null 2>&1; then
  echo "Removing Firefox snap..."
  sudo snap remove --purge firefox
fi

# === Install Firefox .deb from Mozilla's APT repo ===
if ! command -v firefox >/dev/null 2>&1 || [[ $(which firefox) == *snap* ]]; then
  echo "Installing Firefox from Mozilla APT repo..."

  # Create keyring directory if it doesn't exist
  sudo install -d -m 0755 /etc/apt/keyrings

  # Import Mozilla's signing key
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

  # Verify the key fingerprint
  FINGERPRINT=$(gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print}')
  if [[ "$FINGERPRINT" == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3" ]]; then
    echo "✔ Firefox key fingerprint verified."
  else
    echo "✖ Firefox key fingerprint verification failed. Exiting for safety."
    exit 1
  fi

  # Add Mozilla repo to sources
  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | \
    sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

  # Set high priority for Mozilla repo
  echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

  # Update and install Firefox
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
