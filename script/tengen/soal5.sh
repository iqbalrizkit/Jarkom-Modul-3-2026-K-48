#!/bin/bash
# /root/soal5.sh  (kumulatif soal 2,4,5,6) - tengen

# --- network tengen ---
ip addr add 192.235.4.10/24 dev eth0 2>/dev/null
ip link set eth0 up
ip route replace 192.235.2.0/24 via 192.235.4.1
ip route replace 192.235.3.0/24 via 192.235.4.1

# --- MAC client (huruf kecil) ---
ITADORI=02:42:21:c0:08:00
FUSHIGURO=02:42:b2:1e:db:00
ZENIN=02:42:ed:eb:1b:00
OKKOTSU=02:42:67:9b:e9:00
INO=f2:dd:ec:51:c9:cb
KUSAKABE=02:42:ad:7b:60:00
MIWA=02:42:aa:19:d8:00
KUGISAKI=02:42:e4:2c:cd:00

cat > /etc/dhcp/dhcpd.conf <<CONF
authoritative;
default-lease-time 600;
max-lease-time 7200;

# Network 4: subnet lokal tanpa pool dinamis
subnet 192.235.4.0 netmask 255.255.255.0 {
}

# Class Divisi A (soal 4)
class "pool1" { match if hardware = 01:$ITADORI or hardware = 01:$FUSHIGURO; }
class "pool2" { match if hardware = 01:$ZENIN   or hardware = 01:$OKKOTSU; }

# Class Divisi B (soal 5)
class "short" { match if hardware = 01:$INO or hardware = 01:$KUSAKABE; }
class "long"  { match if hardware = 01:$MIWA; }

# Network 2
subnet 192.235.2.0 netmask 255.255.255.0 {
    option routers 192.235.2.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.235.2.255;
    option domain-name-servers 192.235.1.2, 192.235.1.3;
    option domain-search "K48.com";
    option domain-name "K48.com";

    pool { allow members of "pool1"; range 192.235.2.10 192.235.2.35; }
    pool { allow members of "pool2"; range 192.235.2.70 192.235.2.95; }
}

# Network 3
subnet 192.235.3.0 netmask 255.255.255.0 {
    option routers 192.235.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.235.3.255;
    option domain-name-servers 192.235.1.2, 192.235.1.3;
    option domain-search "K48.com";
    option domain-name "K48.com";

    pool {
        allow members of "short";
        range 192.235.3.10 192.235.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }
    pool {
        allow members of "long";
        range 192.235.3.100 192.235.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }

    # Soal 6: fixed address (di luar semua pool)
    host kugisaki {
        hardware ethernet $KUGISAKI;
        fixed-address 192.235.3.99;
        default-lease-time 43200;
        max-lease-time 43200;
    }
}
CONF

touch /var/lib/dhcp/dhcpd.leases
dhcpd -t -cf /etc/dhcp/dhcpd.conf && service isc-dhcp-server restart
service isc-dhcp-server status
echo "== TENGEN READY =="
