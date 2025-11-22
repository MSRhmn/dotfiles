#!/bin/bash

set -e

echo "Starting Postman installation..."

# Check if Postman is already installed
if command -v postman &>/dev/null || [ -d "/opt/Postman" ]; then
    echo "Postman is already installed. Aborting installation."
    exit 0
fi

# 1. Download the latest Postman Linux 64-bit tarball
echo "Downloading Postman..."
wget https://dl.pstmn.io/download/latest/linux64 -O /tmp/postman.tar.gz

# 2. Extract the tarball to /opt/
echo "Extracting Postman to /opt/..."
sudo tar -xzf /tmp/postman.tar.gz -C /opt/

# 3. Create a symbolic link for easy execution
echo "Creating symbolic link /usr/bin/postman..."
sudo ln -sf /opt/Postman/Postman /usr/bin/postman

# 4. Create a desktop entry for Postman
echo "Creating desktop entry..."
sudo bash -c 'cat > /usr/share/applications/postman.desktop <<EOL
[Desktop Entry]
Name=Postman
Exec=postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Type=Application
Categories=Development;
EOL'

# 5. Clean up the downloaded tarball
echo "Cleaning up..."
rm /tmp/postman.tar.gz

echo "Postman installation complete!"
