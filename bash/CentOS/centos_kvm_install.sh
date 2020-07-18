#!/bin/bash

# Install KVM on CentOS Server
# Install required packages
yum -y install @virt* dejavu-lgc-* xorg-x11-xauth tigervnc \ libguestfs-tools policycoreutils-python bridge-utils

# Set Sellinux context
semanage fcontext -a -t virt_image_t “/vm(/.*)?”; restorecon -R /vm

# Allow packet forwarding
sed -i ‘s/^\(net.ipv4.ip_forward =\).*/\1 1/’ /etc/sysctl.conf; sysctl -p

# Configure libvirtd
chkconfig libvirtd on; shutdown -r now

# Host Setup Complete, Setup Virtual Containers
# View available OS templates
virt-install –os-variant=list | more

# Select an OS variant
OS=”–os-variant=freebsd8″

OS=”–os-variant=win7″

OS=”–os-variant=win7 –disk path=/var/lib/libvirt/iso/virtio-win.iso,device=cdrom”

OS=”–os-variant=win2k8″

OS=”–os-variant=win2k8 –disk path=/var/lib/libvirt/iso/virtio-win.iso,device=cdrom”

OS=”–os-variant=rhel6″

# Select a network option
Net=”–network bridge=br0″ Net=”–network model=virtio,bridge=br0″

Net=”–network model=virtio,mac=52:54:00:00:00:00″

Net=”–network model=virtio,bridge=br0,mac=52:54:00:00:00:00″

# Select a disk option
Disk=”–disk /vm/Name.img,size=8″

Disk=”–disk /var/lib/libvirt/images/Name.img,size=8″

Disk=”–disk /var/lib/libvirt/images/Name.img,sparse=false,size=8″

Disk=”–disk /var/lib/libvirt/images/Name.qcow2,sparse=false,bus=virtio,size=8″ Disk=”–disk vol=pool/volume” Disk=”–livecd –nodisks”

Disk=”–disk /dev/mapper/vg_…”

# Select a source
Src=”–cdrom=/var/lib/libvirt/iso/iso/…”

Src=”–pxe”

Src=”-l http://alt.fedoraproject.org/pub/fedora/linux/releases/20/Fedora/x86_64/os/” Src=”-l http://download.fedoraproject.org/pub/fedora/linux/releases/20/Fedora/x86_64/os/”

Src=”-l http://ftp.us.debian.org/debian/dists/stable/main/installer-amd64/ Src=”-l http://ftp.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/”

Src=”-l http://download.opensuse.org/distribution/openSUSE-stable/repo/oss/” Src=”–location=http://mirror.centos.org/centos/6/os/x86_64″

# Select Number of CPU's 
Cpu=”–vcpus=1″

Cpu=”–vcpus=2″

Cpu=”–vcpus=4″

# Select Amount of RAM
Ram=”–ram=768″ Ram=”–ram=1024″ Ram=”–ram=2048″

# Choose name for the guest
Name=”myvps”

# Create the guest
virt-install $OS $Net $KS $Disk $Src $Gr $Cpu $Ram –name=$Name

# Connect to the console
virt-viewer –connect qemu_ssh://myvps/$Name

# You can set htis VPS to boot on server Startup
virsh autostart $Name
