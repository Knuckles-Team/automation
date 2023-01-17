FROM ubuntu:latest AS cockpit
RUN apt update && apt upgrade -y && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata wget curl git cockpit cockpit-machines cockpit-docker cockpit-system cockpit-bridge cockpit-storaged cockpit-networkmanager net-tools traceroute dos2unix
RUN wget https://launchpad.net/ubuntu/+source/cockpit/215-1~ubuntu19.10.1/+build/18889196/+files/cockpit-docker_215-1~ubuntu19.10.1_all.deb
RUN apt install ./cockpit-docker_215-1~ubuntu19.10.1_all.deb