#!/bin/bash

set -euo pipefail

echo "=== Starting System Setup ==="
sudo apt update
. /etc/os-release

# Core packages
DESKTOP_ENV=$(echo "${XDG_CURRENT_DESKTOP:-}" | tr '[:upper:]' '[:lower:]')

PACKAGES=(
  ca-certificates
  gnupg
  apt-transport-https
  curl
  git
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
  rclone
  fd-find
  fzf
  mediainfo
  bat
  ncdu
  zip
  unzip
  gnome-system-monitor
  gparted
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

# === Install OBS Studio ===
# OBS publishes an official PPA for Ubuntu 26.04 and newer. Older supported
# Ubuntu releases use the package from their own archive.
if dpkg --compare-versions "$VERSION_ID" ge 26.04; then
  sudo apt install -y software-properties-common
  if ! grep -Rqs 'ppa.launchpadcontent.net/obsproject/obs-studio' /etc/apt/sources.list.d; then
    sudo add-apt-repository -y ppa:obsproject/obs-studio
    sudo apt update
  fi
fi
sudo apt install -y obs-studio

# === Install Dropbox ===
if ! dpkg -s dropbox >/dev/null 2>&1; then
  if [[ "$(dpkg --print-architecture)" == "amd64" ]]; then
    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://linux.dropbox.com/fedora/rpm-public-key.asc |
      sudo tee /etc/apt/keyrings/dropbox.asc >/dev/null
    sudo chmod 644 /etc/apt/keyrings/dropbox.asc

    if ! grep -Rqs 'linux.dropbox.com/ubuntu' /etc/apt/sources.list.d; then
      echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/dropbox.asc] https://linux.dropbox.com/ubuntu ${VERSION_CODENAME} main" |
        sudo tee /etc/apt/sources.list.d/dropbox.list >/dev/null
    fi

    sudo apt update
    sudo apt install -y dropbox
  else
    echo "Skipping Dropbox: the packaged desktop app is available for amd64 only."
  fi
fi

# === Install Syncthing ===
if ! dpkg -s syncthing >/dev/null 2>&1; then
  sudo install -d -m 0755 /etc/apt/keyrings
  curl -fsSL https://syncthing.net/release-key.gpg |
    sudo tee /etc/apt/keyrings/syncthing-archive-keyring.gpg >/dev/null
  sudo chmod 644 /etc/apt/keyrings/syncthing-archive-keyring.gpg

  if ! grep -Rqs 'apt.syncthing.net' /etc/apt/sources.list.d; then
    cat <<EOF | sudo tee /etc/apt/sources.list.d/syncthing.sources >/dev/null
Types: deb
URIs: https://apt.syncthing.net/
Suites: syncthing
Components: stable-v2
Signed-By: /etc/apt/keyrings/syncthing-archive-keyring.gpg
EOF
  fi

  sudo apt update
  sudo apt install -y syncthing
fi

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
export NVM_DIR="$HOME/.nvm"

if [ ! -d "$NVM_DIR" ]; then
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
  echo "nvm is already installed."
fi

# Load nvm from its standard per-user location.
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

# === Install Obsidian ===
if ! dpkg -s obsidian >/dev/null 2>&1; then
  if [[ "$(dpkg --print-architecture)" == "amd64" ]]; then
    echo "=== Installing Obsidian ==="
    OBSIDIAN_RELEASE_INFO=$(
      curl -fsSL https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest |
        python3 -c 'import json, sys; asset=next(asset for asset in json.load(sys.stdin)["assets"] if asset["name"].startswith("obsidian_") and asset["name"].endswith("_amd64.deb")); print(asset["browser_download_url"], asset.get("digest", "").removeprefix("sha256:"), sep="\t")'
    )
    IFS=$'\t' read -r OBSIDIAN_DEB_URL OBSIDIAN_SHA256 <<< "$OBSIDIAN_RELEASE_INFO"
    OBSIDIAN_TMP_DIR=$(mktemp -d)
    if ! curl -fsSL "$OBSIDIAN_DEB_URL" -o "$OBSIDIAN_TMP_DIR/obsidian.deb" ||
      [[ ! "$OBSIDIAN_SHA256" =~ ^[[:xdigit:]]{64}$ ]] ||
      [[ "$(sha256sum "$OBSIDIAN_TMP_DIR/obsidian.deb" | awk '{print $1}')" != "$OBSIDIAN_SHA256" ]] ||
      [[ "$(dpkg-deb -f "$OBSIDIAN_TMP_DIR/obsidian.deb" Package 2>/dev/null)" != "obsidian" ]]; then
      rm -rf -- "$OBSIDIAN_TMP_DIR"
      echo "Obsidian download was invalid; installation stopped." >&2
      exit 1
    fi
    sudo apt install -y "$OBSIDIAN_TMP_DIR/obsidian.deb"
    rm -rf -- "$OBSIDIAN_TMP_DIR"
  else
    echo "Skipping Obsidian: this installer currently supports its amd64 .deb only."
  fi
fi

# === Install VeraCrypt ===
if ! dpkg -s veracrypt >/dev/null 2>&1; then
  if [[ "$(dpkg --print-architecture)" == "amd64" ]]; then
    VERACRYPT_DEB_URL=$(
      curl -fsSL https://veracrypt.io/en/Downloads.html |
        python3 -c 'import re, sys; page=sys.stdin.read(); version=re.escape(sys.argv[1]); match=re.search(r"https://github[.]com/veracrypt/VeraCrypt/releases/download/[^/]+/veracrypt-[^/]+-Ubuntu-" + version + r"-amd64[.]deb", page); print(match.group(0) if match else "")' "$VERSION_ID"
    )

    if [[ -n "$VERACRYPT_DEB_URL" ]]; then
      echo "=== Installing VeraCrypt ==="
      VERACRYPT_TMP_DIR=$(mktemp -d)
      export GNUPGHOME="$VERACRYPT_TMP_DIR/gnupg"
      mkdir -m 0700 "$GNUPGHOME"

      if ! curl -fsSL "$VERACRYPT_DEB_URL" -o "$VERACRYPT_TMP_DIR/veracrypt.deb" ||
        ! curl -fsSL "${VERACRYPT_DEB_URL}.sig" -o "$VERACRYPT_TMP_DIR/veracrypt.deb.sig" ||
        ! curl -fsSL https://amcrypto.jp/VeraCrypt/VeraCrypt_PGP_public_key.asc |
          gpg --batch --import; then
        rm -rf -- "$VERACRYPT_TMP_DIR"
        unset GNUPGHOME
        echo "Could not download VeraCrypt and its signing key." >&2
        exit 1
      fi

      VERACRYPT_FINGERPRINT=$(gpg --batch --with-colons --fingerprint | awk -F: '$1 == "fpr" {print $10; exit}')
      if [[ "$VERACRYPT_FINGERPRINT" != "5069A233D55A0EEB174A5FC3821ACD02680D16DE" ]] ||
        ! gpg --batch --verify "$VERACRYPT_TMP_DIR/veracrypt.deb.sig" "$VERACRYPT_TMP_DIR/veracrypt.deb" ||
        [[ "$(dpkg-deb -f "$VERACRYPT_TMP_DIR/veracrypt.deb" Package 2>/dev/null)" != "veracrypt" ]]; then
        rm -rf -- "$VERACRYPT_TMP_DIR"
        unset GNUPGHOME
        echo "VeraCrypt package signature or package metadata was invalid." >&2
        exit 1
      fi

      sudo apt install -y "$VERACRYPT_TMP_DIR/veracrypt.deb"
      rm -rf -- "$VERACRYPT_TMP_DIR"
      unset GNUPGHOME
    else
      echo "Skipping VeraCrypt: no official amd64 package is listed for Ubuntu $VERSION_ID."
    fi
  else
    echo "Skipping VeraCrypt: this installer currently supports its amd64 .deb only."
  fi
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
