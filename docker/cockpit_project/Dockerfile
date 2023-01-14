FROM ubuntu:latest AS cockpit_base
RUN apt update && apt upgrade -y && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata wget curl git cockpit cockpit-machines net-tools traceroute dos2unix
FROM cockpit_base as cockpit
COPY start_server.sh /bin/start-server
RUN chmod +x /bin/start-server
CMD ["start-server"]