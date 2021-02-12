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
	sudo apt-get install -y phoronix-test-suite
}

function centos_install(){
	# Update & Install Dependencies
	sudo yum update -y
	sudo yum -y install wget php-cli php-xml bzip2 json php-pear php-devel gcc make php-pecl-json
	# Download Phoronix rpm
	cd ~/Downloads
	wget https://phoronix-test-suite.com/releases/phoronix-test-suite-9.8.0.tar.gz
	# Unzip in Downloads
	sudo tar xvfz phoronix-test*.tar.gz
	cd phoronix-test-suite
	sudo ./install-sh
}

function main(){
  detect_os
}

main
