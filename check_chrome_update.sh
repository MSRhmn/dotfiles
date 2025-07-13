#!/bin/bash

# Function to get the latest Chrome stable version from Google's repository
get_latest_chrome_version() {
    local metadata
    metadata=$(curl -fsSL https://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/Packages)
    if [[ $? -ne 0 || -z "$metadata" ]]; then
        echo "Error: Failed to fetch Google Chrome repository metadata." >&2
        exit 1
    fi
    latest_version=$(echo "$metadata" | grep -A 10 "Package: google-chrome-stable" | grep -m1 "Version:" | awk '{print $2}' | cut -d'-' -f1)
    if [[ -z "$latest_version" ]]; then
        echo "Error: Could not parse latest Chrome stable version." >&2
        exit 1
    fi
    echo "$latest_version"
}

# Function to get the latest Chrome stable package filename
get_latest_chrome_filename() {
    local metadata
    metadata=$(curl -fsSL https://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/Packages)
    if [[ $? -ne 0 || -z "$metadata" ]]; then
        echo "Error: Failed to fetch Google Chrome repository metadata." >&2
        exit 1
    fi
    filename=$(echo "$metadata" | grep -A 10 "Package: google-chrome-stable" | grep -m1 "Filename:" | awk '{print $2}')
    if [[ -z "$filename" ]]; then
        echo "Error: Could not parse Chrome stable filename." >&2
        exit 1
    fi
    echo "$filename"
}

# Function to get the locally installed Chrome stable version
get_local_chrome_version() {
    if command -v google-chrome-stable &> /dev/null; then
        local_version=$(google-chrome-stable --version | awk '{print $3}')
        echo "$local_version"
    elif command -v google-chrome &> /dev/null; then
        local_version=$(google-chrome --version | awk '{print $3}')
        echo "$local_version"
    else
        echo "not_installed"
    fi
    # Warn if google-chrome-beta is installed
    if command -v google-chrome-beta &> /dev/null; then
        echo "Warning: google-chrome-beta is installed and may cause conflicts."
    fi
}

# Function to compare versions
compare_versions() {
    local v1=$1
    local v2=$2
    if [[ $v1 == $v2 ]]; then
        return 0
    fi
    lower_version=$(printf '%s\n' "$v1" "$v2" | sort -V | head -n1)
    if [[ $lower_version == $v1 ]]; then
        return 1
    else
        return 2
    fi
}

# Function to add Google's Chrome repository
add_chrome_repo() {
    echo "Adding Google Chrome repository..."
    if ! grep -q "dl.google.com/linux/chrome/deb" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-archive-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | \
            sudo tee /etc/apt/sources.list.d/google-chrome.list
        if [[ $? -ne 0 ]]; then
            echo "Failed to add Google Chrome repository."
            exit 1
        fi
    fi
}

# Function to remove google-chrome-beta if installed
remove_chrome_beta() {
    if command -v google-chrome-beta &> /dev/null; then
        echo "Removing google-chrome-beta to avoid conflicts..."
        sudo apt-get remove -y google-chrome-beta
        if [[ $? -ne 0 ]]; then
            echo "Failed to remove google-chrome-beta. Please remove it manually."
            exit 1
        fi
    fi
}

# Function to update Chrome via apt
update_chrome_apt() {
    echo "Attempting to update Google Chrome via apt..."
    sudo apt-get update
    sudo apt-get install --only-upgrade -y google-chrome-stable
    if [[ $? -eq 0 ]]; then
        new_version=$(get_local_chrome_version)
        compare_versions "$new_version" "$latest_version"
        if [[ $? -eq 0 ]]; then
            echo "Google Chrome has been successfully updated to version $new_version"
            return 0
        else
            echo "Apt update did not install the latest version (expected $latest_version, got $new_version)."
            return 1
        fi
    else
        echo "Apt update failed."
        return 1
    fi
}

# Function to update Chrome via direct download
update_chrome_direct() {
    echo "Falling back to direct download of Google Chrome $latest_version..."
    remove_chrome_beta
    filename=$(get_latest_chrome_filename)
    deb_url="https://dl.google.com/linux/chrome/deb/$filename"
    temp_deb="/tmp/google-chrome-stable_${latest_version}.deb"
    echo "Downloading from $deb_url..."
    curl -fsSL "$deb_url" -o "$temp_deb"
    if [[ $? -ne 0 ]]; then
        echo "Specific version download failed. Trying current stable package..."
        deb_url="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
        curl -fsSL "$deb_url" -o "$temp_deb"
        if [[ $? -ne 0 ]]; then
            echo "Failed to download Chrome package."
            rm -f "$temp_deb"
            exit 1
        fi
    fi
    sudo dpkg -i "$temp_deb"
    if [[ $? -ne 0 ]]; then
        echo "Failed to install Chrome package. Trying to fix dependencies..."
        sudo apt-get install -f -y
        if [[ $? -ne 0 ]]; then
            echo "Failed to fix dependencies."
            rm -f "$temp_deb"
            exit 1
        fi
    fi
    rm -f "$temp_deb"
    new_version=$(get_local_chrome_version)
    compare_versions "$new_version" "$latest_version"
    if [[ $? -eq 0 ]]; then
        echo "Google Chrome has been successfully updated to version $new_version"
    else
        echo "Direct download installed version $new_version, but expected $latest_version."
        exit 1
    fi
}

# Function to install Chrome
install_chrome() {
    echo "Installing Google Chrome..."
    remove_chrome_beta
    add_chrome_repo
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable
    if [[ $? -eq 0 ]]; then
        echo "Google Chrome has been successfully installed, version $(get_local_chrome_version)"
    else
        echo "Apt installation failed. Trying direct download..."
        update_chrome_direct
    fi
}

# Main script
echo "Checking for Google Chrome updates..."

# Remove google-chrome-beta at the start
remove_chrome_beta

# Get versions
latest_version=$(get_latest_chrome_version)
local_version=$(get_local_chrome_version)

if [[ $local_version == "not_installed" ]]; then
    echo "Google Chrome is not installed on this system."
    read -p "Would you like to install Google Chrome version $latest_version? (y/n): " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        install_chrome
    else
        echo "Installation cancelled."
        exit 0
    fi
else
    echo "Current installed version: $local_version"
    echo "Latest available version: $latest_version"

    # Compare versions
    compare_versions "$local_version" "$latest_version"
    result=$?

    if [[ $result -eq 0 ]]; then
        echo "Your Google Chrome is up to date."
        exit 0
    elif [[ $result -eq 1 ]]; then
        echo "A newer version of Google Chrome is available."
        read -p "Would you like to update to version $latest_version? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
            add_chrome_repo
            update_chrome_apt || update_chrome_direct
        else
            echo "Update cancelled."
            exit 0
        fi
    fi
fi
