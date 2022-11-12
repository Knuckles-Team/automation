#!/bin/bash

export WORKDIR="/services"
export SERVERURL="192.168.1.XXX"

mkdir -p ${WORKDIR}/wireguard
mkdir -p ${WORKDIR}/ddclient

sudo ufw allow 51820/udp

sudo docker-compose up -d
