FROM ubuntu:latest AS ubuntu
RUN apt update && apt upgrade -y && apt install wget curl git cockpit cockpit-machines net-utils
FROM ubuntu as cockpit
COPY ./start_server.sh /bin/start-server
RUN chmod +x /bin/start-server
CMD ["start-server"]