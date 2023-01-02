;
; BIND data file for local loopback interface
;
$TTL    20
@       IN      SOA     jellyfin.heaven.com. root.jellyfin.com. (
                                2               ; Serial
                                20              ; Refresh
                                20              ; Retry
                                20              ; Expire
                                20 )            ; Negative Cache TTL
;
@       IN      NS      jellyfin.heaven.com.
@       IN      A       192.168.1.62
www     IN      A       192.168.1.62
@       IN      AAAA    1234:1234::1
