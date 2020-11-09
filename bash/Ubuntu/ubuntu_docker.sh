#!/bin/bash

sudo apt update

# Install Ubuntu APT Version
sudo apt install -y \
  containerd \
  docker.io \
  docker-compose
  


:'
# Install CE Version (From Docker Repo)
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common \ 
    
    
    
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose -y
'
sudo docker run hello-world

#sudo groupadd docker
#sudo usermod -aG docker mrdr
#sudo su - mrdr

# Start Docker
sudo systemctl start docker
# Enable Docker at Startup
sudo systemctl enable docker

# docker exec -it <container name> /bin/bash

#sudo docker network create --subnet=172.18.0.0/16 container_network
# Uninstall Docker
#sudo apt-get purge docker-ce docker-ce-cli containerd.io
#sudo rm -rf /var/lib/docker 

