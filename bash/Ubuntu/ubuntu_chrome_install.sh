#!/bin/sh

sudo apt update
sudo apt install curl wget -y
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
sudo apt update
sudo rm ./google-chrome-stable_current_amd64.deb
