#!/bin/bash

echo "Updating First"
sudo apt update
sudo apt upgrade -y

printf "Installing all applications"
sudo ./ubuntu_chrome_install.sh
sudo ./ubuntu_nfs_server.sh
sudo ./ubuntu_python_env_install.sh
sudo ./ubuntu_python_update.sh
sudo ./ubuntu_kvm.sh
sudo ./ubuntu_vlc.sh
sudo ./ubuntu_steam.sh
sudo ./ubuntu_git_config.sh
sudo ./ubuntu_docker.sh
sudo ./ubuntu_gimp.sh
sudo ./ubuntu_wireshark.sh
sudo ./ubuntu_transmissionqt.sh
sudo ./ubuntu_gparted.sh
sudo ./ubuntu_dos2unix.sh
printf "Applications installed successfully"

