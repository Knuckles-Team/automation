FROM lscr.io/linuxserver/ddclient:latest AS ddclient
ARG PASSWORD="PASSWORD"
ARG PASSWORD="USERNAME"
ARG SERVERURL="SERVERURL"
ARG SERVER="SERVER"
ENV PASSWORD=${PASSWORD}
ENV USERNAME=${USERNAME}
ENV URL=${URL}
ENV SERVER=${SERVER}
RUN apk update && apk upgrade
RUN apk add --no-cache curl tar make gcc build-base wget gnupg ca-certificates g++ git gd-dev
RUN apk add --no-cache zlib zlib-dev
RUN apk add --no-cache perl perl-dev
RUN apk add --no-cache perl-app-cpanminus
RUN cpanm App::cpm
RUN cpanm --sudo Digest::SHA1
RUN echo -e 'run_dhclient="false"\nrun_ipup="true"\nrun_daemon="false"\ndaemon_interval="300"' | tee /etc/default/ddclient
RUN echo -e "daemon=5m\ntimeout=10\nsyslog=yes\npid=/var/run/ddclient.pid\nssl=yes\n\nuse=if, if=eth0\nserver=${SERVER}/\nprotocol=freedns\nlogin=${USERNAME}\npassword='${PASSWORD}'\n${SERVERURL}" | tee /ddclient.conf
RUN echo -e "daemon=5m\ntimeout=10\nsyslog=yes\npid=/var/run/ddclient.pid\nssl=yes\n\nuse=if, if=eth0\nserver=${SERVER}/\nprotocol=freedns\nlogin=${USERNAME}\npassword='${PASSWORD}'\n${SERVERURL}" | tee /ddclient.conf
