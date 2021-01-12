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
	# Install Dependencies
	sudo apt install curl wget bridge-utils cpu-checker qemu-kvm virtinst libvirt-daemon virt-manager -y
	kvm-ok

	# Enable libvirtd service
	sudo systemctl enable --now libvirtd
	lsmod | grep -i kvm

	# create the network.xml file
	sudo echo '<network>
	<name>vmbr0</name>
	<forward mode="route"/>
	<bridge name="vmbr0" stp="on" delay="0"/>
		<ip address="192.168.0.1" netmask="255.255.0.0">
		  <dhcp>
		    <range start="192.168.0.2" end="192.168.255.254"/>
		  </dhcp>
		</ip>
	</network>' >> network.xml

	sudo cp ./network.xml /root/
	cat /root/network.xml
	# will define, create, and start our new network.
	sudo virsh net-define /root/network.xml
	sudo virsh net-autostart vmbr0
	sudo virsh net-start vmbr0
	# delete the default private network, this is not required but you can if you prefer to delete it
	#sudo virsh net-destroy default
	#sudo virsh net-undefine default
	# restart the libvirt daemon.
	sudo systemctl restart libvirtd.service
	# Enable IPv4 and IPv6 packet forwarding!
	sudo sed -i "/net.ipv4.ip_forward=1/ s/# *//" /etc/sysctl.conf
	sudo sed -i "/net.ipv6.conf.all.forwarding=1/ s/# *//" /etc/sysctl.conf
	# Reload sysctl for the packet forwarding changes to be applied.
	sudo sysctl -p

	vm=c8-02g ; time sudo virt-install --name "${vm}" \
	--memory 2048 \
	--vcpus=1 \
	--os-variant=centos7.0 \
	--accelerate \
	--graphics none \
	--disk path=/var/lib/libvirt/images/"${vm}".qcow2,size=10 \
	--location /home/mrdr/Downloads/CentOS-8.2.2004-x86_64-dvd1.iso \
	--initrd-inject=/home/mrdr/Documents/automation/bash/Ubuntu/ks.cfg \
	--debug \
	--network bridge=vmbr0 \
	--console pty,target_type=serial \
	--extra-args "console=ttyS0,115200n8 serial auto=true priority=critical ks=file:/ks.cfg SERVERNAME=${vm} net.ifnames=0 biosdevname=0" 
}

function centos_install(){
	# Install KVM on CentOS Server
	# Install required packages
	yum -y install @virt* dejavu-lgc-* xorg-x11-xauth tigervnc \ libguestfs-tools policycoreutils-python bridge-utils

	# Set Sellinux context
	semanage fcontext -a -t virt_image_t “/vm(/.*)?”; restorecon -R /vm

	# Allow packet forwarding
	sed -i ‘s/^\(net.ipv4.ip_forward =\).*/\1 1/’ /etc/sysctl.conf; sysctl -p

	# Configure libvirtd
	chkconfig libvirtd on; shutdown -r now
}

function main(){
  detect_os
}

main
