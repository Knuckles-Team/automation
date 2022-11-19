Prerequisites:
- ddclient
- ufw

```bash
sudo apt install ddclient
sudo apt install net-tools
```

Make sure server has port firewall open

Install ddclient on the server and configure it with subdomain details

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
SERVER="<SERVER>"
SERVERURL="<URL>"
TZ="<TIMEZONE>"
COMPOSE_HTTP_TIMEOUT=<30-300>
SERVERPORT=51820
```
