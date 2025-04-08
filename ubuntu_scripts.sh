#!/bin/bash

# === Show weekday in GNOME clock ===
gsettings set org.gnome.desktop.interface clock-show-weekday true
echo "✔ GNOME clock set to show weekday"

# === Set default editor (interactive) ===
echo "➤ To set the default terminal editor (e.g. nano, vim), you'll now be prompted:"
sudo update-alternatives --config editor

# === Enable Scrollable Tab Strip for Chromium-based browsers (manual flag) ===
echo "🔧 Open your Chromium/Chrome-based browser and go to the following URL:"
echo "    chrome://flags/#scrollable-tabstrip"
echo "Then enable: Scrollable TabStrip"
echo

# === Microsoft Edge: Enable Scrollable Tab Strip (autostart config) ===
EDGE_DESKTOP_FILE="/usr/share/applications/microsoft-edge.desktop"
if [ -f "$EDGE_DESKTOP_FILE" ]; then
  echo "➤ Updating Microsoft Edge desktop file for ScrollableTabStrip..."
  sudo sed -i 's|^Exec=/usr/bin/microsoft-edge-stable %U|Exec=/usr/bin/microsoft-edge-stable --enable-features=ScrollableTabStrip %U|' "$EDGE_DESKTOP_FILE"
  echo "✔ ScrollableTabStrip enabled in Microsoft Edge launcher."
else
  echo "⚠ Microsoft Edge .desktop file not found at $EDGE_DESKTOP_FILE"
fi

# === Enable click-to-minimize for GNOME dock ===
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
echo "✔ GNOME dock set to minimize on click"

# === Suggest Bengali fonts (manual step) ===
echo "🔎 To search for Bengali fonts, run:"
echo "    apt-cache search bengali | grep font"
