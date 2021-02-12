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
	sudo apt install ntfs-3g -y
	rest_of_install
}

function centos_install(){
	sudo yum install epel-release -y
	sudo yum install ntfs-3g -y
	rest_of_install
}

function rest_of_install(){
	sudo mkdir "/media/${USER}/hdd_storage"
	sudo mkdir "/media/${USER}/file_storage"
	sudo mkdir "/media/${USER}/windows"
	sudo mkdir "/media/${USER}/movies"
	sudo mkdir "/media/${USER}/games"

	# If these fstab directories exist, update them. Otherwise create an entry for them.
	sudo grep -q '^/dev/sda1' /etc/fstab && sudo sed -i "s#/dev/sda1.*#/dev/sda1 /media/${USER}/hdd_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sda1 /media/${USER}/hdd_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab

	sudo grep -q '^/dev/sdb2' /etc/fstab && sudo sed -i "s#/dev/sdb2.*#/dev/sdb2 /media/${USER}/file_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sdb2 /media/${USER}/file_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab

	sudo grep -q '^/dev/sdc4' /etc/fstab && sudo sed -i "s#/dev/sdc4.*#/dev/sdc4 /media/${USER}/windows ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sdc4 /media/${USER}/windows ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab

	sudo grep -q '^/dev/sde2' /etc/fstab && sudo sed -i "s#/dev/sde2.*#/dev/sde2 /media/${USER}/movies ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sde2 /media/${USER}/movies ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab

	sudo grep -q '^/dev/sdf2' /etc/fstab && sudo sed -i "s#/dev/sdf2 /media/${USER}/games ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sdf2 /media/${USER}/games ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab

	sudo mount -a
}

function main(){
  detect_os
}

main
