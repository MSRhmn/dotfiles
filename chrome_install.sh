#!/bin/bash

REPO_URL="https://dl.google.com/linux/chrome/deb"
METADATA_URL="$REPO_URL/dists/stable/main/binary-amd64/Packages"
KEYRING_PATH="/usr/share/keyrings/google-chrome-archive-keyring.gpg"
CHROME_REPO_FILE="/etc/apt/sources.list.d/google-chrome.list"

fetch_metadata() {
    metadata=$(curl -fsSL "$METADATA_URL")
    if [[ $? -ne 0 || -z $metadata ]]; then
        echo "Error: Failed to fetch Google Chrome repository metadata." >&2
        exit 1
    fi
}

get_latest_version() {
    echo "$metadata" | awk '/Package: google-chrome-stable/,/SHA256/ { if ($1=="Version:") {print $2; exit} }' | cut -d'-' -f1
}

get_local_version() {
    if command -v google-chrome-stable &> /dev/null; then
        google-chrome-stable --version | awk '{print $3}'
    elif command -v google-chrome &> /dev/null; then
        google-chrome --version | awk '{print $3}'
    else
        echo "not_installed"
    fi
}

add_chrome_repo() {
    if ! grep -q "dl.google.com/linux/chrome/deb" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        echo "Adding Google Chrome repository..."
        curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o "$KEYRING_PATH"
        echo "deb [arch=amd64 signed-by=$KEYRING_PATH] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee "$CHROME_REPO_FILE"
        if [[ $? -ne 0 ]]; then
            echo "Failed to add Google Chrome repository." >&2
            exit 1
        fi
    fi
}

install_chrome() {
    echo "Installing Google Chrome..."
    add_chrome_repo
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable
    if [[ $? -eq 0 ]]; then
        echo "Google Chrome installed successfully, version $(get_local_version)."
    else
        echo "Installation failed."
        exit 1
    fi
}

# Main logic
local_version=$(get_local_version)
if [[ "$local_version" == "not_installed" ]]; then
    fetch_metadata
    latest_version=$(get_latest_version)
    read -p "Google Chrome is not installed. Install version $latest_version? (y/n): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        install_chrome
    else
        echo "Installation cancelled."
        exit 0
    fi
else
    echo "Google Chrome is already installed (version $local_version). Installation skipped."
fi
