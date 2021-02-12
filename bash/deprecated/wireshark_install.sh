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
	echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
	sudo DEBIAN_FRONTEND=noninteractive apt install wireshark -y
}

function centos_install(){
	sudo yum install wireshark wireshark-qt -y
}

function main(){
  detect_os
}

main
