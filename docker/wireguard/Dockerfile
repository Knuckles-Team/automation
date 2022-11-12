FROM linuxserver/wireguard as wireguard
RUN apt update -qq && apt upgrade -y && apt install -y ddclient nano vim wget
RUN echo -e "\
# /etc/ddclient.conf \n\
syslog=yes              # log the output to syslog \n\
mail=root               # send email notifications to root \n\
mail-failure=root       # send email when failed \n\
ssl=yes                 # use ssl when updating IP \n\
use=web, web=dynamicdns.park-your-domain.com/getip # look up external IP from this URL \n\
protocol=namecheap \n\
server=dynamicdns.park-your-domain.com \n\
login=your-domain.com \n\
password=your-ddns-password \n\
@,*    # wildcard, to update all subdomains, like a.your-domain.com, b.your-domain.com \n\
" | tee /etc/ddclient.conf
RUN sed -i 's/run_daemon="false"/run_daemon="true"/' /etc/default/ddclient
RUN sed -i 's/run_ipup="true"/run_ipup="false"/' /etc/default/ddclient
RUN systemctl restart ddclient
RUN systemctl enable ddclient
