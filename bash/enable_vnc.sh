#!/bin/bash

sudo apt update
sudo apt upgrade -y
sudo apt install tasksel -y
sudo apt install slim -y
cat /etc/X11/default-display-manager
# tasksel - Run this if you need to install ubuntu desktop
sudo apt install tigervnc-standalone-server -y
vncserver -localhost no
vncserver -list