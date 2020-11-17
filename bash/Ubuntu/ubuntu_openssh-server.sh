#!/bin/bash

# Install SSH
sudo apt update
sudo apt install openssh-server -y

# View Status of SSH Server
sudo systemctl status ssh

# Create Firewall Rule for SSH
sudo ufw allow ssh
