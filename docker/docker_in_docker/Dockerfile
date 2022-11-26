FROM ubuntu:latest as ubuntu
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy nano vim gcc git dos2unix jq curl wget build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip && \
    curl -sSL https://get.docker.com/ | sh