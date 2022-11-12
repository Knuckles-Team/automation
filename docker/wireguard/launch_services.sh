#!/bin/bash

export WORKDIR=/services
mkdir -p ${WORKDIR}/wireguard
mkdir -p ${WORKDIR}/ddclient

sudo ufw allow 51820/udp

echo "examplepassword" | tee ./data/wireguard/password.txt

export SERVERURL="192.168.1.XXX"

sudo docker-compose up -d
