#!/bin/bash

# This script automates the installation of Postman on Linux.
echo "Starting Postman installation..."

# 1. Download the latest Postman Linux 64-bit tarball
echo "Downloading Postman..."
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz

# Check if download was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to download Postman. Exiting."
    exit 1
fi

# 2. Extract the tarball to /opt/
echo "Extracting Postman to /opt/..."
sudo tar -xzf postman.tar.gz -C /opt/

# Check if extraction was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract Postman. Do you have sudo permissions? Exiting."
    rm postman.tar.gz # Clean up downloaded file
    exit 1
fi

# 3. Create a symbolic link for easy execution
echo "Creating symbolic link /usr/bin/postman..."
sudo ln -sf /opt/Postman/Postman /usr/bin/postman

# Check if symlink creation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to create symbolic link. Exiting."
    rm postman.tar.gz # Clean up downloaded file
    exit 1
fi

# 4. Create a desktop entry for Postman
echo "Creating desktop entry for Postman at /usr/share/applications/postman.desktop..."
sudo bash -c 'cat > /usr/share/applications/postman.desktop <<EOL
[Desktop Entry]
Name=Postman
Exec=postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Type=Application
Categories=Development;
EOL'

# Check if desktop entry creation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to create desktop entry. Exiting."
    rm postman.tar.gz # Clean up downloaded file
    exit 1
fi

# 5. Clean up the downloaded tarball
echo "Cleaning up downloaded file..."
rm postman.tar.gz

echo "Postman installation complete! You should now find Postman in your applications menu."
echo "You can also run it from the terminal by typing 'postman'."
