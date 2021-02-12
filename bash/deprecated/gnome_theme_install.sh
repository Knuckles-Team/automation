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
	sudo apt install -y snapd gnome-tweaks gnome-shell-extensions gnome-shell-extension-ubuntu-dock
	sudo snap install orchis-themes
	for i in $(snap connections | grep gtk-common-themes:gtk-3-themes | awk '{print $2}'); do sudo snap connect $i orchis-themes:gtk-3-themes; done
}

function centos_install(){
	echo "For Ubuntu Only, not compatible with CentOS"
}

function main(){
  detect_os
}

main