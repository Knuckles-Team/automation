#!/bin/sh

sudo apt update
# Install Dependencies
sudo apt install curl wget nfs-common nfs-kernel-server -y

sudo mkdir /var/nfs/general -p
ls -la /var/nfs/general
sudo chown nobody:nogroup /var/nfs/general

# Add the directory desired to /etc/exports file
sudo nano /etc/exports
sudo systemctl restart nfs-kernel-server

# Check IP
ip a
# Fix Firewall 
sudo ufw status
sudo ufw allow from client_ip to any port nfs
sudo ufw status
