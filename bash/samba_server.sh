#!/bin/bash
sudo apt update
sudo apt install -y samba
mkdir /home/<username>/sambashare/
sudo nano /etc/samba/smb.conf
echo -e "[sambashare]
    comment = Samba on Ubuntu
    path = /home/username/sambashare
    read only = no
    browsable = yes" | tee -a /etc/samba/smb.conf
sudo service smbd restart
sudo ufw allow samba
sudo smbpasswd -a username