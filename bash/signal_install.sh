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
	cd ~/Downloads/	
	wget -O- https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
	echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
	sudo apt update
	sudo apt install signal-desktop -y
}

function centos_install(){
	sudo flatpak install flathub org.signal.Signal
}

function main(){
  detect_os
}

main
