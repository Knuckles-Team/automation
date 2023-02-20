# Vagrant Kubernetes Environment 

## Installation
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
