#!/bin/bash

echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update -y
apt-get install -y isc-dhcp-relay

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="192.235.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
EOF

sysctl -w net.ipv4.ip_forward=1

service isc-dhcp-relay restart