# Run: sudo docker build -t stressng . && sudo docker run -t stressng

FROM ubuntu:latest

COPY run_stress-ng.sh /run_stress-ng.sh

RUN echo "Testing stress-ng ubuntu" \
 && mkdir -p /logs \
 && apt update \
 && apt install -y apt-utils \
 && apt upgrade -y \
 && apt install -y stress-ng mesa-utils dos2unix \
 && chmod +x /*.sh \
 && dos2unix /*.sh

CMD script -q -c "/run_stress-ng.sh 20s" /logs/stress-ng.log \
 && echo -e "\n\n\nStress-ng log" \
 && cat /logs/stress-ng.log && echo -e "\n\nSuccess\n\n"
