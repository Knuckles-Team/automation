
Make sure server has port firewall open

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
URL="<URL>"
TZ="<TIMEZONE>"
COMPOSE_HTTP_TIMEOUT=<30-300>
```