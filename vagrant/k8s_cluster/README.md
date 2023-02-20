# Vagrant Kubernetes Environment 

## Installation

### Package Manager
```bash
sudo apt -y install apt-transport-https ca-certificates curl software-properties-common virtualbox wget
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install vagrant
```

### Manual
```bash
export VAGRANT_VERSION=2.3.4
apt install virtualbox curl
curl -O https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb
sudo apt install ./vagrant_${VAGRANT_VERSION}_x86_64.deb
```

## Bring up Environment
```bash
cd /path/to/Vagrantfile
vagrant up
```

## ssh into the virtual machine
```bash
vagrant ssh
```

## You can stop the virtual machine with the following command
```bash
vagrant halt
```

## Destroy all resources
```bash
vagrant destroy
```

[More information](https://linuxize.com/post/how-to-install-vagrant-on-ubuntu-20-04/)
