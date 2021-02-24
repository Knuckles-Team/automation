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
	# Updating packages from repositories.
	sudo apt update
	# Install update manager
	sudo apt install update-manager-core -y

	# Upgrading Distrubution
	sudo apt dist-upgrade -y

	# House Cleaning
	# The first line will remove/fix any residual/broken packages if any.
	sudo apt --purge autoremove -y
	# The clean command removes all old .deb files from the apt cache (/var/cache/apt/archives)
	sudo apt clean all -y
	# Removes package configurations left over from packages that have been removed (but not purged).
	#sudo apt purge $(dpkg -l | awk '/^rc/ { print $2 }') -y

	# Upgrading OS
	sudo do-release-upgrade
	# Forcefull upgrade.
	# sudo do-release-upgrade -d

	# Check latest release
	lsb_release -a
}

function centos_install(){
	sudo yum check-update
	sudo yum update -y
	sudo yum upgrade
	sudo yum clean all
}

function main(){
  detect_os
}

main
