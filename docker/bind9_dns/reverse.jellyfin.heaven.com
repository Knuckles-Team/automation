;
; BIND reverse data file for local loopback interface
;
$TTL    20
@       IN      SOA     jellyfin.heaven.com. root.jellyfin.com. (
                                1               ; Serial
                                20              ; Refresh
                                20              ; Retry
                                20              ; Expire
                                20 )            ; Negative Cache TTL
;
@       IN      NS      jellyfin.heaven.com.
62      IN      PTR     jellyfin.heaven.com.