# Run: sudo docker build -t stressng . && sudo docker run -t stressng

FROM ubuntu:latest

RUN echo "Testing stress-ng ubuntu" \
 && mkdir -p /logs \
 && mkdir -p /content \
 && apt update \
 && apt install -y apt-utils \
 && apt upgrade -y \
 && apt install -y stress-ng mesa-utils dos2unix \
 && chmod +x /*.sh \
 && dos2unix /*.sh

COPY run_stress-ng.sh /content/run_stress-ng.sh

CMD script -q -c "/content/run_stress-ng.sh 20s" /logs/stress-ng.log \
 && echo -e "\n\n\nStress-ng log" \
 && cat /logs/stress-ng.log && echo -e "\n\nSuccess\n\n"
