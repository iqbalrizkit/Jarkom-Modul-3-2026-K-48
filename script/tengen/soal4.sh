#!/bin/bash

# 1. Set DNS Resolver
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 2. Update & Install DHCP Server
apt-get update -y
apt-get install -y isc-dhcp-server

# 3. Konfigurasi /etc/dhcp/dhcpd.conf Soal 4
cat > /etc/dhcp/dhcpd.conf << 'EOC'
# --- Class Tim Dev (itadori & fushiguro) ---
class "Dev-Team" {
    match if hardware = 01:02:42:21:c0:08:00 or hardware = 01:02:42:b2:1e:db:00;
}

# --- Class Tim Support (zenin & okkotsu) ---
class "Support-Team" {
    match if hardware = 01:02:42:ed:eb:1b:00 or hardware = 01:02:42:67:9b:e9:00;
}

# Subnet Lokal Tengen (Network 4)
subnet 192.235.4.0 netmask 255.255.255.0 {
}

# Subnet Divisi A (Network 2)
subnet 192.235.2.0 netmask 255.255.255.0 {
    option routers 192.235.2.1;
    option domain-name-servers 192.168.122.1;

    # Pool 1: Tim Dev (192.235.2.10 - 192.235.2.35)
    pool {
        allow members of "Dev-Team";
        range 192.235.2.10 192.235.2.35;
    }

    # Pool 2: Tim Support (192.235.2.70 - 192.235.2.95)
    pool {
        allow members of "Support-Team";
        range 192.235.2.70 192.235.2.95;
    }
}

# Subnet Network 3
subnet 192.235.3.0 netmask 255.255.255.0 {
    option routers 192.235.3.1;
    option domain-name-servers 192.168.122.1;
}

EOC

# 4. Interface Default, Reset Lease & Service Restart
sed -i 's/INTERFACESv4=""/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server
pkill -9 dhcpd 2>/dev/null
rm -f /var/run/dhcpd.pid
echo "" > /var/lib/dhcp/dhcpd.leases
dhcpd -t
service isc-dhcp-server restart
