#!/bin/bash

sudo apt update
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt install wireshark -y
