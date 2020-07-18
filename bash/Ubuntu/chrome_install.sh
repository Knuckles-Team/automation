#!/bin/bash

swupd bundle-add package-utils
curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
sudo rpm --import https://dl-ssl.google.com/linux/linux_signing_key.pub
rpm -i --nodeps google-chrome*.rpm
sed -i 's\/usr/bin/google-chrome-stable\env FONTCONFIG_PATH=/usr/share/defaults/fonts /usr/bin/google-chrome-stable\g' /usr/share/applications/google-chrome.desktop
rm -f google-chrome*.rpm
