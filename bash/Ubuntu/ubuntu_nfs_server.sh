#!/bin/sh

nfs_directory="/mnt/nfs/"

sudo apt update
# Install Dependencies
sudo apt install curl wget nfs-common nfs-kernel-server net-tools -y

sudo mkdir ${nfs_directory} -p
ls -la ${nfs_directory}
sudo chown -R nobody:nogroup ${nfs_directory}
sudo chmod 777 ${nfs_directory}

# Acquire My IP address for the NFS Server
my_interface=$(ip route get 8.8.8.8 | awk -F"dev " 'NR==1{split($2,a," ");print a[1]}')
my_ip=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
my_netmask=$(/sbin/ifconfig "${my_interface}" | awk '/inet /{ print $4;} ')
my_ip_subnet=$(ip -o -f inet addr show | awk '/scope global/ {print $2 " " $4}' | grep "${my_interface}" | awk '{print $2}')
printf "${my_interface} \n${my_ip} \n${my_netmask} \n${my_ip_subnet}\n\n\n\n"

# Add the directory desired to /etc/exports file
echo "${nfs_directory}  *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports

# Export the NFS Share Directory
sudo exportfs -a

# Restart NFS Kernel Server
sudo systemctl restart nfs-kernel-server
sudo systemctl enable nfs-kernel-server

# Fix Firewall (IF ACTIVE)
#sudo ufw status
#sudo ufw allow from client_ip to any port nfs
#sudo ufw status
