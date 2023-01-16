FROM ubuntu:latest AS virtualization_base
RUN apt update && apt upgrade -y && apt install -y wget curl git traceroute cpu-checker qemu-kvm virt-manager libvirt-daemon-system virtinst libvirt-clients bridge-utils
FROM vivirtualization_basetualization AS virtualization
COPY ./vm-manager.sh /bin/vm-manager
RUN dos2unix /bin/vm-manager
RUN chmod +x /bin/vm-manager
CMD ["vm-manager"]