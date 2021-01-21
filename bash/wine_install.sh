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
	sudo apt update
	# Older version of wine
	sudo apt install wine -y
	# Enable 32bit on OS
#	sudo dpkg --add-architecture i386
#	wget -nc https://dl.winehq.org/wine-builds/winehq.key
#	sudo apt-key add winehq.key
#	sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ groovy main'
}

function centos_install(){
	sudo yum install wine -y
}

function main(){
  detect_os
}

main
