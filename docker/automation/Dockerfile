# docker run -v /mnt:/mnt -it name-of-image bash
FROM ubuntu:latest as base-ubuntu
RUN apt update
RUN apt install update-manager-core -y
RUN apt dist-upgrade -y
RUN mkdir -p /automation
FROM base-ubuntu as upgraded-ubuntu
COPY automation.tar.gz /automation/automation.tar.gz
RUN tar -xvf /automation/automation.tar.gz -C /automation | tee -a /provision_log.txt
RUN chmod +x /automation/bash/*.sh | tee -a /provision_log.txt
RUN bash /automation/bash/system-manager -u -p -t server | tee -a /provision_log.txt
FROM upgraded-ubuntu as provisioned-ubuntu
RUN theme-manager -i -t | tee -a /provision_log.txt
RUN theme-manager -h | tee -a /provision_log.txt
RUN video-manager -h | tee -a /provision_log.txt
RUN video-downloader -h | tee -a /provision_log.txt
RUN system-manager -h | tee -a /provision_log.txt
