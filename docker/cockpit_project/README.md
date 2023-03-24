```bash
[WebService]
Origins = https://cockpit.r510.heavenhomestead.com http://cockpit.r510.arpa:9090
ProtocolHeader = X-Forwarded-Proto
ForwardedForHeader = X-Forwarded-For
AllowUnencrypted = true
ClientCertAuthentication = false
[Service]
Environment=G_TLS_GNUTLS_PRIORITY=NORMAL:-VERS-SSL3.0:-VERS-TLS1.0:-VERS-TLS1.1
```

in

/etc/cockpit/cockpit.conf