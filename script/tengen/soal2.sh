#!/bin/bash

echo "nameserver 192.168.122.1" > /etc/resolv.conf

apt-get update -y
apt-get install -y isc-dhcp-server

cat > /etc/dhcp/dhcpd.conf << 'EOC'
subnet 192.235.4.0 netmask 255.255.255.0 {
}

subnet 192.235.2.0 netmask 255.255.255.0 {
    range 192.235.2.10 192.235.2.35;
    option routers 192.235.2.1;
    option domain-name-servers 192.168.122.1;
}

subnet 192.235.3.0 netmask 255.255.255.0 {
    range 192.235.3.10 192.235.3.50;
    option routers 192.235.3.1;
    option domain-name-servers 192.168.122.1;
}
EOC

sed -i 's/INTERFACESv4=""/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server
pkill -9 dhcpd 2>/dev/null
rm -f /var/run/dhcpd.pid
echo "" > /var/lib/dhcp/dhcpd.leases
dhcpd -t
service isc-dhcp-server restart
