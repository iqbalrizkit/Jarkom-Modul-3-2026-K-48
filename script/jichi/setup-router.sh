#!/bin/bash

echo "nameserver 192.168.122.1" > /etc/resolv.conf

cat > /etc/network/interfaces << 'EOF'
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 192.235.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.235.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.235.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 192.235.4.1
    netmask 255.255.255.0
EOF

ifup eth1 eth2 eth3 eth4 2>/dev/null

sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf 2>/dev/null

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
