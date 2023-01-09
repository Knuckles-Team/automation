FROM ubuntu:latest AS ubuntu
RUN apt update && apt upgrade -y && apt install -y dos2unix lm-sensors ipmitool wget curl git python3 python-is-python3 python3-pip gcc
RUN python -m pip install --upgrade pip
RUN python -m pip install --upgrade fan-manager>=0.4.0
CMD ["fan-manager", "--intensity", "5", "--cold", "50", "--warm", "80", "--slow", "5", "--fast", "100", "--poll-rate", "24"]
