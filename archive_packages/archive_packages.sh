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
