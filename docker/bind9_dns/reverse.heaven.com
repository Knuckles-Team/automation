;
; BIND reverse data file for local loopback interface
;
$TTL    20
@       IN      SOA     heaven.com.         root.heaven.com. (
                                1               ; Serial
                                20              ; Refresh
                                20              ; Retry
                                20              ; Expire
                                20 )            ; Negative Cache TTL
;
@       IN      NS      heaven.com.
62      IN      PTR     heaven.com.