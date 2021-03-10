#!/bin/bash

function usage() {
  echo "Usage: "
  echo "sudo ./dhcp_tftp_server.sh --install"
  echo "sudo ./dhcp_tftp_server.sh --dhcp"
  echo "sudo ./dhcp_tftp_server.sh --new-iso"
}
function install() {
  sudo apt update
  sudo apt upgrade -y
  sudo apt install -y snapd wget curl tftpd-hpa p7zip-full inetutils isc-dhcp-server net-tools jq gcc genisoimage make \
  xz-utils bridge-utils tmux apt-transport-https sshpass

  # Check IP address before modification
  ip a

  current_private_ip=$(ifconfig ${private_network_adapter} | awk '/inet /{print $2}')
  if [[ "${private_ip}" != "${current_private_ip}" ]]; then
    sudo ifconfig ${private_network_adapter} ${private_ip} netmask 255.255.0.0
    echo "Private IP address set to ${private_ip}"
  else
    echo "Private IP address already set to ${private_ip}"
  fi

  # Check IP address after modification
  ip a

  # Show Network Interface config files
  ls /etc/netplan
  # Additional work may need to be done here to disable/enable network adapters

  # Set the DHCP Configuration file
  set_dhcp

  # Uncomment IPv4 forwarding
  sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

  # Print the file to ensure it was changed
  cat /etc/sysctl.conf

  # Check current postrouting rules
  sudo iptables -t nat -L -n -v --line-number

  # Flush default/existing postrouting rules.
  sudo iptables -t nat -F POSTROUTING

  # Set secondary network adapter for routing
  sudo iptables -t nat -A POSTROUTING -o ${public_network_adapter} -j MASQUERADE

  # Confirm IP tables configuration change
  sudo iptables -t nat -L -n -v --line-number

  # Add any additional rules to prevent internal network from reaching external network

  # Make the changes persistent
  echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
  echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

  # Make tables persistent
  sudo apt install -y iptables-persistent

  # Modify interface rules
  sudo sed -i "s#INTERFACESv4=\"\"#INTERFACESv4=\"${private_network_adapter}\"#" /etc/default/isc-dhcp-server
  grep -q '^INTERFACES=' /etc/default/isc-dhcpserver && sudo sed -i "s#^INTERFACES=.*#INTERFACES=\"${private_network_adapter}\"#" /etc/default/isc-dhcp-server || echo -e "INTERFACES=\"${private_network_adapter}\"" | sudo tee -a /etc/default/isc-dhcp-server
  cat /etc/default/isc-dhcp-server

  # Restart DHCP Service
  sudo service isc-dhcp-server restart
  exitcode=$(echo $?)
  if [ $exitcode -eq 0 ]; then
    echo "DHCP Server install successfully"
  fi

  # Navigate to TFTP boot directory
  sudo mkdir -p ${tftp_directory}
  cd ${tftp_directory} || echo "Directory not found"

  # Configure TFTP Server Settings
  grep -q '^TFTP_USERNAME=' ${tftp_config} && sudo sed -i 's#^TFTP_USERNAME=.*#TFTP_USERNAME="tftp"#' ${tftp_config} || echo -e 'TFTP_USERNAME="tftp"' | sudo tee -a ${tftp_config}
  grep -q '^TFTP_DIRECTORY=' ${tftp_config} && sudo sed -i "s#^TFTP_DIRECTORY=.*#TFTP_DIRECTORY=\"${tftp_directory}\"#" ${tftp_config} || echo -e "TFTP_USERNAME=\"${tftp_directory}\"" | sudo tee -a ${tftp_config}
  grep -q '^TFTP_ADDRESS=' ${tftp_config} && sudo sed -i 's#^TFTP_ADDRESS=.*#TFTP_ADDRESS="0.0.0.0:69"#' ${tftp_config} || echo -e 'TFTP_ADDRESS="0.0.0.0:69"' | sudo tee -a ${tftp_config}
  grep -q '^TFTP_OPTIONS=' ${tftp_config} && sudo sed -i 's#^TFTP_OPTIONS=.*#TFTP_OPTIONS="--secure --create"#' ${tftp_config} || echo -e 'TFTP_OPTIONS="--secure --create"' | sudo tee -a ${tftp_config}
  cat ${tftp_config}

  # Give TFTP ownership of its directory
  sudo chown tftp:tftp ${tftp_directory}

  # Restart TFTP service
  sudo systemctl restart tftp-hpa
  exitcode=$(echo $?)
  if [ $exitcode -eq 0 ]; then
    echo "TFTP Server install successfully"
  fi
  set_image
}

function set_dhcp() {
  # Configure network interfaces
  echo "auto ${public_network_adapter}
iface ${public_network_adapter} inet static
address ${public_ip}
netmask 255.255.0.0
gateway $(echo '${public_ip}' | awk -F. '{print $1"."$2"."}').0.1

auto ${private_network_adapter}
iface ${private_network_adapter} inet static
address ${private_ip}
netmask 255.255.128.0
broadcast 192.168.127.255
network 192.168.0.0
" | sudo tee /etc/network/interfaces

  # Network YAML file.
  echo "network:
version: 2
renderer: networkd
ethernets:
  ${public_network_adapter}:
    dhcp4: true
    dhcp-identifier: mac
  ${private_network_adapter}:
    dhcp4: no
    addresses: [${private_ip}/16]
    nameservers:
      addresses: [1.1.1.1,8.8.8.8]
" | sudo tee /etc/netplan/vagrant.yaml

  # DHCP Configuration File
  echo '# DHCP CONF - PXE DHCP and General DHCP
authoritative;
allow booting;
allow bootp;

class "PXE_Clients" {
  match if substring(option vendor-class-identifier, 0, 9) = "PXEClient";
  log(info, "Found PXE Client on network");
}

share-network private-network {
  # General subnet 32,768 IP Addresses
  subnet 192.168.0.0 netmask 255.255.128.0 {
    default-lease-time 2592000;
    max-lease-time 2592000;

    option subnet-mask 255.255.128.0;
    option routers 192.168.0.1;
    option domain-name-servers 1.1.1.1,8.8.8.8;
    option broadcast-address 192.168.127.255;

    pool {
      range 192.168.0.2 192.168.127.254;
      log(info, "allocated IP to general machine);
    }
  }

  # PXE Subnet 32,768 IP Addresses
  subnet 192.168.128.0 netmask 255.255.128.0 {
    filename "tftpboot/mboot.efi";

    option subnet-mask 255.255.128.0;
    option routers 192.168.128.1;
    option domain-name-servers 1.1.1.1,8.8.8.8;
    option broadcast-address 192.168.128.255;

    pool {
      range 192.168.128.2 192.168.255.254;
      allow members of "PXE_Clients";
      log(info, "allocated IP to PXE Client");
    }
  }
}
' | sudo tee /etc/dhcp/dhcpd.conf

  cat /etc/dhcp/dhcpd.conf

  # Restart all networking services
  sudo netplan --debug generate
  sudo netplan generate
  sudo netplan apply
  sudo systemctl restart networking
  sudo service isc-dhcp-server restart
  ip a

  # Debug
  # sudo service isc-dhcp-server status
  # sudo tail -n 50 -f /var/log/syslog
  # dhcpd -t -cf /etc/dhcp/dhcpd.conf
  # ip addr flush dev eth0
  # ip addr flush dev dockervirbr0

}

function set_image() {
  echo "Setting image: ${iso_name}"

  # Remove existing netboot image
  sudo rm -rf "${tftp_directory}/*"

  # Copy ISO to TFTP ISO Directory
  sudo mkdir -p "${iso_directory}"
  sudo cp -a "${iso_name}" "${iso_directory}"

  # Extract ISO
  cd "${iso_directory}" || echo "ISO directory not found"
  sudo 7z x ${iso_name} -y

  # Copy UEFI Bootloader to TFTP Boot
  sudo cp ${iso_directory}/EFI/BOOT/BOOTX64.EFI ${tftp_directory}/mboot.efi
  ls -ls ${tftp_directory}/*

  # Modify boot.cfg to point to kickstart file to TFTP Server
  grep -q '^kernelopt=' ${boot_cfg} && sudo sed -i "s#kernelopt=.*#kernelopt=ks=http://${public_ip}${kickstart}#" ${boot_cfg} || echo -e "kernelopt=ks=http://${public_ip}${kickstart}" | sudo tee -a ${boot_cfg}
  #cat ${boot_cfg}
  # Modify boot.cfg to point to kickstart file to TFTP Server in the ISO file
  grep -q '^kernelopt=' ${boot_original_cfg} && sudo sed -i "s#kernelopt=.*#kernelopt=ks=http://${public_ip}${kickstart}#" ${boot_original_cfg} || echo -e "kernelopt=ks=http://${public_ip}${kickstart}" | sudo tee -a ${boot_original_cfg}

  # Create kickstart file
  echo '# Automated Installation Kickstart
# File: /mnt/public/Support/Platforms/CentOS8/centos8-ks.cfg
# Locations:
#    /mnt/public/Support/Platforms/CentOS8/centos8-ks.cfg
# Author: bgstack15
# Startdate: 2017-06-02
# Title: Kickstart for CentOS 8 for ipa.example.com
# Purpose: To provide an easy installation for VMs and other systems in the Mersey network
# History:
#    2017-06 I learned how to use kickstart files for the RHCSA EX-200 exam
#    2017-08-08 Added notifyemail to --extra-args
#    2017-10-29 major revision to use local repository
#
#
#
#
#    2019-09-24 fork for CentOS 8
# Usage with virt-install:
#    vm=c8-01a ; time sudo virt-install -n "${vm}" --memory 2048 --vcpus=1 --os-variant=centos7.0 --accelerate -v --disk path=/var/lib/libvirt/images/"${vm}".qcow2,size=20 -l /mnt/public/Support/SetupsBig/Linux/CentOS-8-x86_64-1905-dvd1.iso --initrd-inject=/mnt/public/Support/Platforms/CentOS8/centos8-ks.cfg --extra-args "ks=file:/centos8-ks.cfg SERVERNAME=${vm} NOTIFYEMAIL=bgstack15@gmail.com net.ifnames=0 biosdevname=0" --debug --network type=bridge,source=br0 --noautoconsole
#    vm=c8-01a; sudo virsh destroy "${vm}"; sudo virsh undefine --remove-all-storage "${vm}";
# Reference:
#    https://sysadmin.compxtreme.ro/automatically-set-the-hostname-during-kickstart-installation/
#    /mnt/public/Support/Platforms/CentOS7/install-vm.txt

#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
# Install OS instead of upgrade
install
# Keyboard layouts
keyboard "us"
# Root password
rootpw --plaintext f0rg3tkickstart&
# my user
user --groups=wheel --name=centvm --password=$6$.gh9u7vg2HDJPPX/$g3X1l.q75fs7i0UKUt6h88bDIo1YSGGj/1DGeUzzbMTb0pBh4of6iNYWyxws/937qUiPgETqOsYFI5XNrkaUe. --iscrypted --gecos="centvm"

# System language
lang en_US.UTF-8
# Firewall configuration
firewall --enabled --ssh
# Reboot after installation
reboot
# Network information
#attempting to put it in the included ks file that accepts hostname from the virsh command.
#network  --bootproto=dhcp --device=eth0 --ipv6=auto --activate
%include /tmp/network.ks
# System timezone
timezone America/New_York --utc
# System authorization information
auth  --useshadow  --passalgo=sha512
# Use network installation instead of CDROM installation media
#url --url="http://www.ipa.example.com/mirror/centos/8/BaseOS/x86_64/os"

# Use text mode install
text
# SELinux configuration
selinux --permissive
# Do not configure the X Window System
skipx

# Use all local repositories
# Online repos
#repo --name=examplerpm --baseurl=http://www.ipa.example.com/example/repo/rpm/
#repo --name=base --baseurl=https://www.ipa.example.com/mirror/centos/$releasever/BaseOS/$basearch/os/
#repo --name=appstream --baseurl=https://www.ipa.example.com/mirror/centos/$releasever/AppStream/$basearch/os/
#repo --name=extras --baseurl=https://www.ipa.example.com/mirror/centos/$releasever/extras/$basearch/os/
#repo --name=powertools --baseurl=https://www.ipa.example.com/mirror/centos/$releasever/PowerTools/$basearch/os/
#repo --name=epel --baseurl=https://www.ipa.example.com/mirror/fedora/epel/$releasever/Everything/$basearch

# Offline repos
#
#
#
#
#

firstboot --disabled

# System bootloader configuration
bootloader --location=mbr
# Partition clearing information
clearpart --all --initlabel
# Disk partitioning information
autopart --type=lvm

%pre
echo "network  --bootproto=dhcp --device=eth0 --ipv6=auto --activate --hostname renameme.ipa.example.com" > /tmp/network.ks
for x in $( cat /proc/cmdline );
do
   case $x in
      SERVERNAME*)
         eval $x
         echo "network  --bootproto=dhcp --device=eth0 --ipv6=auto --activate --hostname ${SERVERNAME}.ipa.example.com" > /tmp/network.ks
         ;;
      NOTIFYEMAIL*)
         eval $x
         echo "${NOTIFYEMAIL}" > /mnt/sysroot/root/notifyemail.txt
  ;;
   esac
done
cp -p /run/install/repo/ca-ipa.example.com.crt /etc/pki/ca-trust/source/anchors/ 2>/dev/null || :
wget http://www.ipa.example.com/example/certs/ca-ipa.example.com.crt -O /etc/pki/ca-trust/source/anchors/ca-ipa.example-wget.com.crt || :
update-ca-trust || :
%end

%post
(
   # Set temporary hostname
   #hostnamectl set-hostname renameme.ipa.example.com;

   ifup eth0
   sed -i -r -e "s/ONBOOT=.*/ONBOOT=yes/;" /etc/sysconfig/network-scripts/ifcfg-e*

   # Get local mirror root ca certificate
   wget http://www.ipa.example.com/example/certs/ca-ipa.example.com.crt -O /etc/pki/ca-trust/source/anchors/ca-ipa.example.com.crt && update-ca-trust

   # Get local mirror repositories
   wget https://www.ipa.example.com/example/repo/rpm/examplerpm.repo -O /etc/yum.repos.d/examplerpm.repo;
   wget http://www.ipa.example.com/example/repo/rpm/examplerpm.mirrorlist -O /etc/yum.repos.d/examplerpm.mirrorlist
   distro=centos8 ; wget https://www.ipa.example.com/example/repo/mirror/example-bundle-${distro}.repo -O /etc/yum.repos.d/example-bundle-${distro}.repo && grep -oP "(?<=^\[).*(?=-example])" /etc/yum.repos.d/example-bundle-${distro}.repo | while read thisrepo; do yum-config-manager --disable "${thisrepo}"; done # NONE TO REMOVE dnf -y remove dnfdragora ; yum clean all ; yum update -y ; # Remove graphical boot and add serial console sed -i -r -e "/^GRUB_CMDLINE_LINUX=/{s/(\s*)(rhgb|quiet)\s*/\1/g;};" -e "/^GRUB_CMDLINE_LINUX=/{s/(\s*)\"$/ console=ttyS0 console=tty1\"/;}" /etc/default/grub grub2-mkconfig > /boot/grub2/grub.cfg

   # postfix is already started by default on centos8
   # Send IP address to myself
   thisip="$( ifconfig 2>/dev/null | awk "/Bcast|broadcast/{print $2}" | tr -cd "[^0-9\.\n]" | head -n1 )"
   {
      echo "${SERVER} has IP ${thisip}."
      echo "system finished kickstart at $( date "+%Y-%m-%d %T" )";
   } | /usr/share/bgscripts/send.sh -f "root@$( hostname --fqdn )" \
      -h -s "${SERVER} is ${thisip}" $( cat /root/notifyemail.txt 2>/dev/null )

   # No changes to graphical boot
   #

   # fix the mkhomedir problem
   systemctl enable oddjobd.service && systemctl start oddjobd.service

   # Personal customizations
   mkdir -p /mnt/bgstack15 /mnt/public
   su bgstack15-local -c "sudo /usr/share/bgconf/bgconf.py"

) >> /root/install.log 2>&1
%end

%packages
@core
@^minimal install
bc
bgconf
bgscripts-core
bind-utils
cifs-utils
cryptsetup
dosfstools
epel-release
expect
firewalld
git
iotop
ipa-client
-iwl*-firmware
mailx
man
mlocate
net-tools
nfs-utils
p7zip
parted
python3-policycoreutils
rpm-build
rsync
screen
strace
sysstat
tcpdump
telnet
vim
wget
yum-utils
%end
' | sudo tee ${kickstart}
  cat ${kickstart}

  # Set folder permissiosn
  sudo chmod -R 777 ${tftp_directory}

  # Confirm netboot image was copied successfully
  ls ${tftp_directory}
  echo "Image set successfully"
}


# IP for server
public_ip=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com)
public_ip=${public_ip:1:-1}
private_ip="192.168.0.1"

# Network adapter names
public_network_adapter="eth0"
private_network_adapter="eth1"

# TFTP server directory
tftp_directory="/srv/tftp"
# TFTP Config file path
tftp_config="/etc/default/tftpd-hpa"

# ISO directory
iso_directory="${tftp_directory}/custom_directory"

# ISO name
iso_name="CentOS.iso"

# Boot.cfg file location for TFTP Server
boot_cfg="${iso_directory}/BOOT.CFG"

# Original Boot.cfg file location for TFTP Server
boot_original_cfg="${iso_directory}/EFI/BOOT/BOOT.CFG"

# Kickstart file location
kickstart="${iso_directory}/KS.CFG"

os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
os_version="${os_version:1:-1}"
set_image_flag='false'
install_flag='false'
set_dhcp_flag='false'

# Check if arguments were provided
if [ -z "$1" ]; then
  usage
  exit 0
fi

while test -n "$1"; do
  case "$1" in
    h | -h | --help)
      usage
      echo "These are your network devices: $(ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d')"
      exit 0
      ;;
    i | -i | --install | install)
      install_flag='true'
      shift
      ;;
    d | -d | --dhcp)
      set_dhcp_flag='true'
      shift
      ;;
    n | -n | --new-iso)
      if [ ${2} ]; then
        iso_name="${2}"
        set_image_flag='true'
        shift
      else
        echo 'ERROR: "-n | --new-iso" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    --)# End of all options.
      shift
      break
      ;;
    -?*)
      printf 'WARNING: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    *)
      shift
      break
      ;;
  esac
done

if [ ${install_flag} == "true" ]; then
  install
  exit 0
fi
if [ ${set_dhcp_flag} == "true" ]; then
  set_dhcp
fi

if [ ${set_image_flag} == "true" ]; then
  set_image
fi


