#!/bin/bash

# Update & Upgrade
sudo apt update && sudo apt -y upgrade

# Remove previous xrdp
sudo apt purge xrdp

# Install xfce
sudo apt install -y xfce4 xfce4-goodies

# Install xrdp
sudo apt  -y install xrdp

# Set Port and other settings
sudo set -i 's#test -x /etc/X11/Xsession && exec /etc/X11/Xsession#\#test -x /etc/X11/Xsession && exec /etc/X11/Xsession#' /etc/xrdp/startwm.sh
sudo set -i 's#exec /bin/sh /etc/X11/Xsession#\#exec /bin/sh /etc/X11/Xsession#' /etc/xrdp/startwm.sh
echo -e "#xce4\nstartxfce4" | sudo tee -a /etc/xrdp/startwm.sh
sudo cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
sudo sed -i 's/3389/3390/g' /etc/xrdp/xrdp.ini
sudo sed -i 's/max_bpp=32/#max_bpp=32\nmax_bpp=128/g' /etc/xrdp/xrdp.ini
sudo sed -i 's/xserverbpp=24/#xserverbpp=24\nxserverbpp=128/g' /etc/xrdp/xrdp.iniecho xfce4-session | tee ~/.xsession#enable dbus
sudo systemctl enable dbus
sudo /etc/init.d/dbus start
sudo /etc/init.d/xrdp start