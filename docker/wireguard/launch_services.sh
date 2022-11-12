#!/bin/bash

export WORKDIR="/services"
export SERVERURL="wireguard.domain.com"

mkdir -p ${WORKDIR}/wireguard
mkdir -p ${WORKDIR}/ddclient

sudo ufw allow 51820/udp

sudo docker-compose up -d
