#!/bin/bash

hypnotix_git="https://github.com/linuxmint/hypnotix/releases/download/1.1/hypnotix_1.1_all.deb"
wget -O /tmp/hypnotix.deb "${hypnotix_git}"
sudo apt install /tmp/hypnotix.deb -y

