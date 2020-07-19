#!/bin/bash

# This script will install CentOS with additional configurations
# Enable NTFS External Storage
sudo ./centos_enable_storage.sh
# Install Latest Chrome
sudo ./centos_chrome_install.sh
# Install FFmpeg
sudo ./centos_ffmpeg_install.sh
# Install Python Developer Environment with PyCharm + Dependencies 
sudo ./centos_python_env_install.sh
# Install + Configures KVM
sudo ./centos_kvm_install.sh
# Install Gparted
sudo ./centos_gparted_install.sh
# Install VLC
sudo ./centos_vlc_install.sh
# Update FFmpeg
sudo ./centos_update_ffmpeg.sh
# Updates all Python Packages
sudo ./centos_update_python.sh
