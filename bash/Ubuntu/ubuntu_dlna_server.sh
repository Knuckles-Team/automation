#!/bin/sh

sudo apt update
sudo apt install rygel -y
# edit /etc/rygel.conf based off man rygel.conf
echo "uris=/mnt/w/Movies;/mnt/z/Music" | sudo tee -a /etc/rygel.conf

#sed -i '' ~/.config/rygel.conf