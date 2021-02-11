#!/bin/bash

function detect_os(){
  os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
	os_version="${os_version:1:-1}"
	architecture="$(uname -m)"
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
  if [[ "${architecture}" == "x86_64" ]] || [[ "${architecture}" == "x86" ]]; then
    cd /tmp
    sudo apt update
    sudo apt install curl wget -y
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install /tmp/google-chrome-stable_current_amd64.deb
    sudo apt update
    rm -rf /tmp/google-chrome-stable_current_amd64.deb
  elif [[ "${architecture}" == "aarch64" ]] || [[ "${architecture}" == "aarch32" ]]; then
    sudo apt install -y chromium-browser
  fi
}

function centos_install(){
	cd /tmp
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	sudo yum install /tmp/google-chrome-stable_current_*.rpm
	rm -rf /tmp/google-chrome-stable_current_amd64.rpm
}

function main(){
  detect_os
}

main
