#!/bin/bash

egrep '(vmx|svm)' /proc/cpuinfo

yum install kvm

yum install qemu-kvm python-virtinst libvirt libvirt-python virt-manager libguestfs-tools

#By default, VMs will only have network access to other VMs on the same server (and to the host itself). If you want the VMs to have access to your VLAN, then you must create a network bridge on the host as explained here.
#
#Edit /etc/sysconfig/network-scripts/ifcfg-eth0 and add the line “BRIDGE=br0” (make sure to remove any static IPs).
#
#Create the file /etc/sysconfig/network-scripts/ifcfg-br0 and add the entries as shown below. You can use static or dhcp. I used static IP in this case.
#
#DEVICE="br0"
#BOOTPROTO="static"
#IPADDR="xxx.xxx.xxx.xxx"
#NETMASK="255.255.255.0"
#ONBOOT="yes"
#TYPE="Bridge"
#NM_CONTROLLED="no"

# https://www.thegeekstuff.com/2014/10/linux-kvm-create-guest-vm/

#Enable IP forwarding in /etc/sysctl.conf by adding the following line:
#
#inet.ipv3.ip_forward=1

rpm -qa | egrep "virt|kvm|qemu"

virt-install \
-n myRHELVM1 \
--description "Test VM with RHEL 6" \
--os-type=Linux \
--os-variant=rhel6 \
--ram=2048 \
--vcpus=2 \
--disk path=/var/lib/libvirt/images/myRHELVM1.img,bus=virtio,size=10 \
--graphics none \
--cdrom /var/rhel-server-6.5-x86_64-dvd.iso \
--network bridge:br0

#n: Name of your virtual machine
#
#description: Some valid description about your VM. For example: Application server, database server, web server, etc.
#
#os-type: OS type can be Linux, Solaris, Unix or Windows.
#
#os-variant: Distribution type for the above os-type. For example, for linux, it can be rhel6, centos6, ubuntu14, suse11, fedora6 , etc.
#
#For windows, this can be win2k, win2k8, win8, win7
#
#ram: Memory for the VM in MB
#
#vcpu: Total number of virtual CPUs for the VM.
#
#disk path=/var/lib/libvirt/images/myRHELVM1.img,bus=virtio,size=10: Path where the VM image files is stored. Size in GB. In this example, this VM image file is 10GB.
#
#graphics none: This instructs virt-install to use a text console on VM serial port instead of graphical VNC window. If you have the xmanager set up, then you can ignore this parameter.
#
#cdrom: Indicates the location of installation image. You can specify the NFS or http installation location (instead of –-cdrom). For example: --location=http://.com/pub/rhel6/x86_64/*
#
#network bridge:br0: This example uses bridged adapter br0. It is also possible to create your own network on any specific port instead of bridged adapter.
#
#If you want to use the NAT then use something like below for the network parameter with the virtual network name known as VMnetwork1. All the network configuration files are located under /etc/libvirt/qemu/networks/ for the virtual machines. For example:
#
#–-network network=VMnetwork1