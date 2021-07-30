FROM centos:latest as centos-base
RUN dnf install -y epel-release
RUN dnf install -y jq dnf-plugins-core numactl wget dmidecode msr-tools efibootmgr lshw \
moreutils unzip sshpass tmux openssh-clients openssh-server qemu-kvm libvirt-devel libvirt-manager \
libguestfs-tools virt-install --allowerasing --skip-broken
RUN dnf install -y 'dnf-command(config-manager)' --allowerasing --skip-broken --nobest

FROM centos-base as centos-dependencies
RUN mkdir -p /virt && mkdir -p /var/logs
COPY virtualization /virt/virtualization
RUN find / -type -f -iname "*.sh" -exec chmod +x {} \;
RUN ln -s /var/logs /virt/virtualization/output/logs

FROM centos-dependencies as centos-setup
RUN /virt/virtualization/source/virt-dep-setup.sh

FROM centos-setup as centos-virtualization
ENTRYPOINT ["/virt/virtualization/source/virt-run.sh"]

