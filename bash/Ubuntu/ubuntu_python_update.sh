#!/bin/sh

# This script will update all installed Python packages and dependencies to ther latest version.
# Update Packages
sudo apt update
sudo apt upgrade -y
# Update PIP
sudo python3 -m pip install --upgrade pip
# Install Python Depedencies
sudo apt install gcc -y 
# Update all Packages
sudo python3 -m pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H python3 -m pip install -U

