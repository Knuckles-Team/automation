#!/bin/bash

# Install SSH
sudo apt update
sudo apt install nmap openssh-server -y

# Start SSH
/etc/init.d/ssh start || echo "Already Started"

# View Status of SSH Server
sudo systemctl status ssh || /etc/init.d/ssh status

# Create Firewall Rule for SSH
sudo ufw allow ssh
