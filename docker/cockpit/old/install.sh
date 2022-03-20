#!/bin/bash

apt update
apt install cockpit cockpit-storaged cockpit-networkmanager cockpit-packagekit cockpit-ostree cockpit-machines cockpit-sosreport cockpit-kdump -y

# If you already have Cockpit on your server, point your web browser to: 
# https://ip-address-of-machine:9090
# https://localhost:9090
