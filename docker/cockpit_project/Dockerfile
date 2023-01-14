FROM ubuntu:latest AS cockpit_base
RUN apt update && apt upgrade -y && apt install -y wget curl git cockpit cockpit-machines net-tools traceroute dos2unix
FROM cockpit_base as cockpit
COPY start_server.sh /bin/start-server
RUN chmod +x /bin/start-server
CMD ["start-server"]