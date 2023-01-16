#!/bin/bash

# Print KVM Host Status
echo "KVM: $(modprobe kvm_intel)"
systemctl start --now libvirtd
systemctl enable --now libvirtd

# Download ISO
wget -nc http://cdimage.ubuntu.com/ubuntu-server/daily/current/bionic-server-arm64.iso

# Create Image
qemu-img create -f raw ubuntu-image.img +2G

# Install VM
sudo virt-install  \
--machine=virt  \
--arch=aarch64  \
--boot loader=/usr/share/qemu-efi/QEMU_EFI.fd  \
--name=bionic-vm2  \
--virt-type=kvm  \
--boot cdrom,hd  \
--network=default,model=virtio  \
--disk path=/ubuntu-image.img,format=raw,device=disk,bus=virtio,cache=none  \
--memory=2048  \
--vcpu=2  \
--cdrom=./bionic-server-arm64.iso  \
--graphics vnc,listen=192.168.1.60  \
--check all=off

# virt-install \
# --name ubuntu_server \
# --description "Ubuntu Server" \
# --os-type=Linux \
# --os-variant=rhel6 \
# --memory=2048 \
# --vcpus=2 \
# --disk path=/var/lib/libvirt/images/myRHELVM1.img,bus=virtio,size=10 \
# --graphics none \
# --cdrom /var/rhel-server-6.5-x86_64-dvd.iso \
# --network bridge:br0

# List All VMs
virsh list --all

# Autostart VM
# virsh autostart ubuntu_server
# # Disable Autostart VM
# virsh autostart --disable ubuntu_server

# # Clone 
# virt-clone \
# --original=ubuntu_server \
# --name=ubuntu_server-clone \
# --file=/var/lib/libvirt/images/ubuntu_server.qcow2
