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
	sudo apt install rygel -y
	rest_of_install
}

function centos_install(){
	sudo yum install rygel -y
}

function rest_of_install(){
	# edit /etc/rygel.conf based off man rygel.conf
	# For WSL2:
	#echo "uris=/mnt/w/Movies;/mnt/z/Music" | sudo tee -a /etc/rygel.conf
	# For Ubuntu
	user=$(whoami)
	echo "uris=/media/${user}/Movies/Movies" | sudo tee -a /etc/rygel.conf
	#sed -i '' ~/.config/rygel.conf
	rest_of_install
}

function main(){
  detect_os
}

main
