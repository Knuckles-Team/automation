docker compose up --build --remove-orphans -d

default.conf
```bash
server {
  listen 80;
  listen [::]:80;
  server_name heaven;

  location / {
    root /usr/share/nginx/html;
    index index.html index.htm;
  }

  location /transmission {
    proxy_pass http://192.168.1.75:9091;
  }

  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
    root /usr/share/nginx/html;
  }
}
```