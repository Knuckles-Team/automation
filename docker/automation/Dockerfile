# docker run -v /mnt:/mnt -it name-of-image bash
FROM ubuntu:latest as base-ubuntu
RUN apt update
RUN apt install update-manager-core -y
RUN apt dist-upgrade -y
RUN mkdir -p /automation
FROM base-ubuntu as upgraded-ubuntu
COPY automation.tar.gz /automation/automation.tar.gz
RUN tar -xvf /automation/automation.tar.gz -C /automation
RUN chmod +x /automation/bash/*.sh
RUN bash /automation/bash/system-manager -u -p -t server
RUN theme-manager -h
RUN theme-manager -t
RUN video-manager -h
RUN system-manager -h
