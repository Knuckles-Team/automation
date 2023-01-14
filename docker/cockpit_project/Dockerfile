FROM ubuntu:latest AS cockpit
RUN apt update && apt upgrade -y && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata wget curl git cockpit cockpit-machines net-tools traceroute dos2unix
