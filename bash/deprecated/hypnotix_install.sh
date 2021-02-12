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
	hypnotix_git="https://github.com/linuxmint/hypnotix/releases/download/1.1/hypnotix_1.1_all.deb"
	wget -O /tmp/hypnotix.deb "${hypnotix_git}"
	sudo apt install /tmp/hypnotix.deb -y
	rm /tmp/hypnotix.deb
}

function centos_install(){
	echo "No Installation Client for ${os_version} available yet"
}

function main(){
  detect_os
}

main
