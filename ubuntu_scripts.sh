# Gnome desktop titlebar weekday
gsettings set org.gnome.desktop.interface clock-show-weekday true

# For changing default editor in linux
sudo update-alternatives --config editor

# Disable tab scrolling in chromium based browser in linux (make it enabled)
chrome://flags/#scrollable-tabstrip

# For microsft edge
sudo vi /usr/share/applications/microsoft-edge.desktop
Exec=/usr/bin/microsoft-edge-stable %U--enable-features=ScrollableTabStrip

# Click to Minimize on Ubuntu
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

# Bnalga font instructions
  - For Bangla fonts list "apt-cache search bengali"
	
# Chrome youtube video horizontal stripe fix in intel based graphics
sudo apt install '*video-intel*'

