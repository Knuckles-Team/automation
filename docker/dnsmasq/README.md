.conf file

```bash
#log all dns queries
log-queries
#dont use hosts nameservers
no-resolv
#use google as default nameservers
server=8.8.4.4
server=8.8.8.8
#explicitly define host-ip mappings
heaven.com=/router/10.1.1.1
address=/server/10.1.1.2
cache-size=1000
```