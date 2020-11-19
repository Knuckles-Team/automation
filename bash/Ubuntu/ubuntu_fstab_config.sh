#!/bin/bash

sudo apt update
sudo apt install ntfs-3g -y

sudo mkdir /media/mrdr/hdd_storage
sudo mkdir /media/mrdr/file_storage
sudo mkdir /media/mrdr/windows
sudo mkdir /media/mrdr/movies
sudo mkdir /media/mrdr/games

echo "/dev/sda1 /media/mrdr/hdd_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
echo "/dev/sdb2 /media/mrdr/file_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
echo "/dev/sdc4 /media/mrdr/windows ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
echo "/dev/sde2 /media/mrdr/movies ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
echo "/dev/sdf2 /media/mrdr/games ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab

sudo mount -a
