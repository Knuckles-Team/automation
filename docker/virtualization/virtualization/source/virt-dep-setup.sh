#!/bin/bash

#set -x

dnf install -y epel-release
dnf install -y jq dnf-plugins-core numactl wget dmidecode msr-tools efibootmgr lshw moreutils unzip sshpass tmux openssh-clients openssh-server qemu-kvm libvirt-devel libvirt virt-manager libguestfs-tools virt-install --allowerasing --skip-broken

dnf config-manager --set-enabled powertools

if grep -q docker /proc1/cgroup; then
  echo "Running in docker container"
  source='/virt/virtualization/source'
  log_dir="/virt/virtualization/output/logs"
else
  echo "Running on bare-metal"
  source="$(pwd)/virtualization/source"
  log_dir="$(pwd)/virtualization/output/logs"
  mkdir -p ${log_dir}
fi

if ! command -v packer &> /dev/null; then
  echo -e "packer could not be found \nInstalling..."
  export VER="1.7.2"
  wget -nc --directory-prefix=${auxiliary} --no-check-certificate https://releases.hashicorp.com/packer/${VER}}/packer_${VER}_linux_amd64.zip

  unzip ${auxiliary}/packer_${VER}_linux_amd64.zip -d ${auxiliary}

  mv ${auxiliary}/packer /usr/local/bin/
else
  echo -e "packer already installed! \nSkipping..."
fi

systemctl start libvirtd
systemctl enable libvirtd

echo "QEMU-KVM Version: $(/usr/libexec/qemu-kvm --version)"
echo "QEMU IMG Version: $(qemu-img --version)"
echo "Virsh Version: $(virsh --version)"
echo "Virt-Manager Version: $(virt-manager --version)"
echo "Packer Version: $(packer --version)"

echo "Done setting up dependencies"

# Set file limit to max
sed -i 's/#DefaultLimitNOFILE=/DefaultLimitNOFILE=65536' /etc/systemd/system.conf
sed -i 's/#DefaultLimitNOFILE=/DefaultLimitNOFILE=65536' /etc/systemd/user.conf
grep -q '^* soft nofile 100000' /etc/security/limits.conf && sed -i 's#^* soft nofile#* soft nofile 100000' /etc/security/limits.conf || \
echo -e "* soft nofile 100000" | tee -a /etc/security/limits.conf
grep -q '^* hard nofile 100000' /etc/security/limits.conf && sed -i 's#^* hard nofile#* hard nofile 100000' /etc/security/limits.conf || \
echo -e "* hard nofile 100000" | tee -a /etc/security/limits.conf
grep -q '^root soft nofile 100000' /etc/security/limits.conf && sed -i 's#^root soft nofile#root soft nofile 100000' /etc/security/limits.conf || \
echo -e "root soft nofile 100000" | tee -a /etc/security/limits.conf
grep -q '^root hard nofile 100000' /etc/security/limits.conf && sed -i 's#^root hard nofile#root hard nofile 100000' /etc/security/limits.conf || \
echo -e "root hard nofile 100000" | tee -a /etc/security/limits.conf
ulimit -S -n 100000

echo "Setup Done"