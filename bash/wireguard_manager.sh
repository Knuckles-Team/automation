#!/bin/bash

sudo apt update
sudo apt upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt install ddclient -y

echo "
# /etc/ddclient.conf
syslog=yes              # log the output to syslog
mail=root               # send email notifications to root
mail-failure=root       # send email when failed
ssl=yes                 # use ssl when updating IP
use=web, web=dynamicdns.park-your-domain.com/getip # look up external IP from this URL
protocol=namecheap
server=dynamicdns.park-your-domain.com
login=your-domain.com
password=your-ddns-password
@,*    # wildcard, to update all subdomains, like a.your-domain.com, b.your-domain.com
" | tee /etc/ddclient.conf

sudo sed -i 's/run_daemon="false"/run_daemon="true"/' /etc/default/ddclient
sudo sed -i 's/run_ipup="true"/run_ipup="false"/' /etc/default/ddclient
sudo systemctl restart ddclient
sudo systemctl status ddclient
sudo systemctl enable ddclient
wget https://git.io/wireguard -O wireguard-install.sh && sudo bash wireguard-install.sh
