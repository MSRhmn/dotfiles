# === Install google chrome ===
if ! command -v google-chrome >/dev/null 2>&1; then

  read -rp "Install Google Chrome? (y/n): " answer

  if [[ "$answer" =~ ^[Yy]$ ]]; then

    echo "=== Installing Google Chrome ==="

    sudo mkdir -p /etc/apt/keyrings

    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub |
      gpg --dearmor |
      sudo tee /etc/apt/keyrings/google-chrome.gpg >/dev/null

    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" |
      sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null

    sudo apt update
    sudo apt install -y google-chrome-stable
  else
    echo "Chrome skipped."
  fi
else
  echo "Google Chrome already installed."
fi

# === Install Microsoft Edge ===
if ! command -v microsoft-edge >/dev/null 2>&1; then
  echo "Installing Microsoft Edge..."

  # Import Microsoft GPG key and add Edge repository
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc |
    sudo gpg --dearmor -o /etc/apt/keyrings/microsoft-edge.gpg

  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" |
    sudo tee /etc/apt/sources.list.d/microsoft-edge.list >/dev/null

  sudo apt update
  sudo apt install -y microsoft-edge-stable
else
  echo "Microsoft Edge is already installed."
fi