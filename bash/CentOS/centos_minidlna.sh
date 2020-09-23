#!/bin/sh

sudo yum install minidlna -y
sudo mv ./minidlna.conf /etc/minidlna.conf
minidlna -f /etc/minidlna.conf
minidlna -R -f /etc/minidlna.conf

sudo echo "[Unit]
Description=miniDLNA
After=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/minidlnad -R -f /etc/minidlna.conf

[Install]
WantedBy=multi-user.target" >> /lib/systemd/system/minidlna.service

sudo chown user: minidlna
sudo chown root:root
sudo chmod 755 minidlna
systemctl enable minidlna.service
systemctl start minidlna.service
