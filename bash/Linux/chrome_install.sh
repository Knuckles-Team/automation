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
  cd ~/Downloads
	sudo apt update
	sudo apt install curl wget -y
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo apt install ./google-chrome-stable_current_amd64.deb
	sudo apt update
	sudo rm ./google-chrome-stable_current_amd64.deb
}

function centos_install(){
	cd ~/Downloads
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	sudo yum install ./google-chrome-stable_current_*.rpm
	rm -f ./google-chrome-stable_current_amd64.rpm
}

function main(){
  detect_os
}

main
