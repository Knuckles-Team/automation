#!/bin/sh

# Update Packages
sudo yum -y update
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo yum -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm
sudo yum -y install vlc
#yum install vlc-core (for minimal headless/server install)
#sudo yum -y install python-vlc
