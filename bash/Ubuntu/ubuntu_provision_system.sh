#!/bin/bash

printf "Installing all applications"
sudo ./ubuntu_chrome_install.sh
sudo ./ubuntu_nfs_server.sh
sudo ./ubuntu_python_env_install.sh
sudo ./ubuntu_python_update.sh
sudo ./ubuntu_kvm.sh
sudo ./ubuntu_docker.sh
sudo ./ubuntu_vlc.sh
sudo ./ubuntu_steam.sh
printf "Applications installed successfully"

