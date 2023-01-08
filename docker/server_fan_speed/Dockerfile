FROM ubuntu:latest AS ubuntu
RUN apt update && apt upgrade -y && apt install -y dos2unix lm-sensors ipmitool wget curl git python3 python-is-python3 python3-pip gcc
COPY fan_speed.py /fan_speed.py
RUN service kmod start
CMD ["/fan_speed.py"]