#!/bin/sh

# Go to Downloads Folder
cd ~/Downloads
# Downloads the latest Chrome Version
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
# Install the downloaded Chrome Installer File
sudo yum install ./google-chrome-stable_current_*.rpm
# Remove the Downloaded Installer File
rm -f google-chrome*.rpm
