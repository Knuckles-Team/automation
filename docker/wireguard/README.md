Prerequisites:
- ddclient
- ufw

```bash
sudo apt install ddclient
sudo apt install net-tools
```

Make sure server has port firewall open

Install ddclient on the server and configure it with subdomain details

Modify: /etc/ddclient.conf
```bash
protocol=freedns \
use=if, if=wlan0 \
login=<USERNAME> \
password=<PASSWORD> \
<DDNS>
```


```bash
sudo apt install ufw
sudo ufw allow 51820/udp
touch .env
nano .env
```
.env file contents:
```bash
USERNAME="<EMAIL/USERNAME>"
PASSWORD="<PASSWORD>"
TZ="<TIMEZONE>"
SERVERPORT=DDNS.PORT
SERVER_URL=DDNS.SERVER.URL
```

Show QR Codes:
```bash
docker exec -it wireguard /app/show-peer 1 2 3 4
```
