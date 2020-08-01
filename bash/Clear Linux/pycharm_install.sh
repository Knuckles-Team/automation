#!/bin/sh

sudo swupd bundle-add desktop
sudo swupd bundle-add python3-tcl
sudo swupd bundle-add c-basic
sudo pip install ./pywinpty-0.5.7-cp39-cp39-win_amd64.whl
flatpak install flathub com.jetbrains.PyCharm-Community
flatpak run com.jetbrains.PyCharm-Community
