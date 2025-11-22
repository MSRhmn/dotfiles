#!/bin/bash

REPO_URL="https://dl.google.com/linux/chrome/deb"
METADATA_URL="$REPO_URL/dists/stable/main/binary-amd64/Packages"
KEYRING_PATH="/usr/share/keyrings/google-chrome-archive-keyring.gpg"
CHROME_REPO_FILE="/etc/apt/sources.list.d/google-chrome.list"
TEMP_DEB="/tmp/google-chrome-stable_update.deb"

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

get_latest_filename() {
    echo "$metadata" | awk '/Package: google-chrome-stable/,/SHA256/ { if ($1=="Filename:") {print $2; exit} }'
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

compare_versions() {
    local v1=$1 v2=$2
    if [[ "$v1" == "$v2" ]]; then
        return 0
    elif dpkg --compare-versions "$v1" "lt" "$v2"; then
        return 1
    else
        return 2
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

install_or_upgrade_apt() {
    sudo apt-get update
    sudo apt-get install --only-upgrade -y google-chrome-stable
}

install_from_deb() {
    local filename=$1
    local url="$REPO_URL/$filename"

    echo "Downloading Chrome package from $url..."
    curl -fsSL "$url" -o "$TEMP_DEB" || {
        echo "Failed to download specific version package; trying current stable package..."
        url="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
        curl -fsSL "$url" -o "$TEMP_DEB" || {
            echo "Failed to download Chrome package." >&2
            rm -f "$TEMP_DEB"
            exit 1
        }
    }

    sudo dpkg -i "$TEMP_DEB" || {
        echo "Package install failed; fixing dependencies..."
        sudo apt-get install -f -y || { echo "Failed to fix dependencies." >&2; rm -f "$TEMP_DEB"; exit 1; }
    }

    rm -f "$TEMP_DEB"
}

# Main update logic
local_version=$(get_local_version)
if [[ "$local_version" == "not_installed" ]]; then
    echo "Google Chrome is not installed. Update skipped."
    exit 0
fi

fetch_metadata
latest_version=$(get_latest_version)

echo "Current Chrome version: $local_version"
echo "Latest Chrome version: $latest_version"

compare_versions "$local_version" "$latest_version"
result=$?

if [[ $result -eq 0 ]]; then
    echo "Google Chrome is already up to date."
    exit 0
elif [[ $result -eq 1 ]]; then
    read -p "Update to version $latest_version? (y/n): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        add_chrome_repo
        install_or_upgrade_apt || {
            echo "apt upgrade failed, falling back to direct package install..."
            filename=$(get_latest_filename)
            install_from_deb "$filename"
        }
        new_version=$(get_local_version)
        if [[ "$new_version" == "$latest_version" ]]; then
            echo "Google Chrome successfully updated to $new_version."
        else
            echo "Warning: Installed version $new_version differs from expected $latest_version."
            exit 1
        fi
    else
        echo "Update cancelled."
        exit 0
    fi
else
    echo "Installed version ($local_version) is newer than repository version ($latest_version). No action taken."
fi
