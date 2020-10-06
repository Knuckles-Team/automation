#!/bin/sh

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

:"
cd ~/Downloads
wget http://cdimage.ubuntu.com/ubuntu-legacy-server/releases/20.04/release/ubuntu-20.04-legacy-server-amd64.iso
sudo virt-install --name ubuntu20v5 \
--ram 4096 \
--disk path=/home/mrdr/Documents/ubuntu20v5,size=8 \
--vcpus 2 \
--os-type linux \
--os-variant ubuntu20.04 \
--network bridge=vmbr0 \
--graphics none \
--console pty,target_type=serial \
--location '/home/mrdr/Downloads/ubuntu-20.04-legacy-server-amd64.iso' \
--extra-args 'console=ttyS0,115200n8 serial auto=true priority=critical file=/cdrom/preseed.cfg debian-installer/language=en debian-installer/country=NL console-setup/ask_detect=false keyboard-configuration/layoutcode=us debian-installer/locale=en_US.UTF-8 localechooser/preferred-locale=en_US.UTF8 initrd=/install/initrd.gz quiet --'
"
#cd ~/Downloads/
#wget http://mirror.netdepot.com/centos/8.2.2004/isos/x86_64/CentOS-8.2.2004-x86_64-dvd1.iso
#sudo virt-install --name=centos-vm --os-variant=centos8 --vcpu=2 --ram=2048 --graphics spice --location=/home/mrdr/Downloads/CentOS-8.2.2004-x86_64-dvd1.iso --network bridge:vibr0 
virsh net-dhcp-leases vmbr0
