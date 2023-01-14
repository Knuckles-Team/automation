FROM ubuntu:latest AS cockpit_base
RUN apt update && apt upgrade -y && apt install wget curl git cockpit cockpit-machines net-tools traceroute
FROM cockpit_base as cockpit
COPY start_server.sh /bin/start-server
RUN chmod +x /bin/start-server
CMD ["start-server"]