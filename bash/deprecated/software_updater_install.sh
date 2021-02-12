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
	sudo apt install update-manager synaptic -y
}

function centos_install(){
	echo "For Ubuntu Only, not compatible with CentOS"
}

function main(){
  detect_os
}

main