#!/bin/bash

if ! grep -q "host kugisaki" /etc/dhcp/dhcpd.conf; then
cat << 'CONF' >> /etc/dhcp/dhcpd.conf

host kugisaki {
    hardware ethernet 02:42:e4:2c:cd:00;
    fixed-address 192.235.3.99;
    default-lease-time 43200;
    max-lease-time 43200;
}
CONF
echo "Configuration added successfully."
else
    echo "Configuration for kugisaki already exists in dhcpd.conf."
fi

dhcpd -t -cf /etc/dhcp/dhcpd.conf

pkill -9 dhcpd 2>/dev/null
rm -f /var/run/dhcpd.pid
service isc-dhcp-server restart

echo "== SOAL 6 TENGEN READY =="