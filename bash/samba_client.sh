#!/bin/bash

sudo mkdir -p /media/share
echo -e "username=example_username\npassword=example_password" | tee ~/.credentials
sudo mount -t cifs -o rw,vers=3.0,credentials=~/.credentials //192.168.18.112/sharedDir /media/share
echo "//192.168.18.112/netflix /mnt/smb cifs rw,nofail,vers=3.0,credentials=~/.credentials
//192.168.18.112/album /mnt/smb cifs rw,nofail,vers=3.0,credentials=~/.credentials
//192.168.18.112/torrents /mnt/smb cifs rw,nofail,vers=3.0,credentials=~/.credentials" | tee -a /etc/fstab