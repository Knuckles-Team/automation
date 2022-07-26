#!/bin/bash

pkg update
pkg upgrade -y

pkg install git python3 termux-tools qemu-utils qemu-common qemu-system-x86_64-headless build-essential -y
python3 -m pip install subshift media-downloader

termux-setup-storage

