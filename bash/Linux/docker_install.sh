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
	sudo apt install -y containerd docker.io docker-compose
	sudo docker run hello-world

	# Start Docker
	sudo systemctl start docker
	# Enable Docker at Startup
	sudo systemctl enable docker
}

function centos_install(){
	sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	sudo yum install docker-ce docker-ce-cli containerd.io -y
	sudo docker run hello-world

	# Start Docker
	sudo systemctl start docker
	# Enable Docker at Startup
	sudo systemctl enable docker
}

function main(){
  detect_os
}

main
