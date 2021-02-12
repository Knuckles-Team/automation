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
	sudo apt install steam -y
}

function centos_install(){
	sudo yum install http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-0.2.noarch.rpm -y
	sudo yum install http://download1.rpmfusion.org/free/fedora/releases/19/Everything/i386/os/libtxc_dxtn-1.0.0-3.fc19.i686.rpm -y
	sudo yum --enablerepo=steam_fedora19 install steam -y
}

function main(){
  detect_os
}

main
