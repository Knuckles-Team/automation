#!/bin/bash

function detect_os(){
  os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  os_version="${os_version:1:-1}"
  echo "${os_version}"
  if [[ $os_version = "Ubuntu" ]] ; then
    echo "Installing for Ubuntu"
    ubuntu_install
  elif [[ $os_version = "CentOS Linux" ]] ; then
    echo "Installing for CentOS"
    centos_install
  else 
    echo "Distribution ${os_version} not supported"
  fi
}

function ubuntu_install(){
  # Update Packages
  sudo apt update
  sudo apt upgrade -y
  # Update PIP
  sudo python3 -m pip install --upgrade pip
  # Install Python Depedencies
  sudo apt install gcc -y
  # Update all Packages
  sudo python3 -m pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H python3 -m pip install -U
}

function centos_install(){
  # Update Packages
  sudo yum -y update
  # Update PIP
  sudo python3 -m pip install --upgrade pip
  sudo python3.8 -m pip install --upgrade pip
  # Install Python Depedencies
  sudo yum install gcc python3-devel python38-devel openssl-devel tcl-thread xz-libs bzip2-devel libffi-devel python3-tkinter python38-tkinter -y
  # Update all Packages
  sudo python3 -m pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H python3 -m pip install -U
  sudo python3.8 -m pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H python3.8 -m pip install -U
}

function main(){
  detect_os
}

main
