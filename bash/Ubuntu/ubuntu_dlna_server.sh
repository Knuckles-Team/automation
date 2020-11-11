#!/bin/sh

sudo apt update
sudo apt install rygel -y
# edit /etc/rygel.conf based off man rygel.conf
# For WSL2:
#echo "uris=/mnt/w/Movies;/mnt/z/Music" | sudo tee -a /etc/rygel.conf
# For Ubuntu
user=$(whoami)
echo "uris=/media/${user}/Movies/Movies" | sudo tee -a /etc/rygel.conf
#sed -i '' ~/.config/rygel.conf
