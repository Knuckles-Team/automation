FROM ubuntu:latest AS ubuntu
RUN apt update && apt upgrade -y && apt install dos2unix ipmitool wget curl git python3 python-is-python3 python3-pip gcc
COPY fan_speed.py /fan_speed.py
CMD ["/fan_speed.py"]