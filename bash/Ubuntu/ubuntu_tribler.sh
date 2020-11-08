#!/bin/sh

sudo apt update
sudo apt install wget -y

cd ~/Downloads
wget https://github.com/Tribler/tribler/releases/download/v7.5.4/tribler_7.5.4_all.deb
sudo apt install -y ./tribler_7.5.4_all.deb
rm -r ./tribler_*.deb
