FROM lscr.io/linuxserver/ddclient:latest AS ddclient
RUN apt install -y cpanminus
RUN cpanm --sudo Digest::SHA1
RUN echo -e 'run_dhclient="false"\nrun_ipup="true"\nrun_daemon="false"\ndaemon_interval="300"' | tee /etc/default/ddclient
RUN echo -e 'daemon=5m\ntimeout=10\nsyslog=yes # log update msgs to syslog\npid=/var/run/ddclient.pid # record PID in file.\nssl=yes # use ssl-support. Works with ssl-library\n\nuse=if, if=eth0\nserver=freedns.afraid.org/\nprotocol=freedns\nlogin=knucklessg1@gmail.com\npassword=\'PASSWORD\'\nheavenvpn.twilightparadox.com' | tee /config/ddclient.config
RUN cp /config/ddclient.config /ddclient.config
RUN service ddclient restart
RUN service ddclient enable
