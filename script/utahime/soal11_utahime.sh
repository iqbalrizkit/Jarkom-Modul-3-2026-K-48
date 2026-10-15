#!/bin/bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update && apt-get install -y bind9 bind9utils dnsutils

mkdir -p /etc/bind/jujutsu
cat > /etc/bind/named.conf.local <<'EOF'
zone "jujutsu.K48.com" {
    type master;
    file "/etc/bind/jujutsu/db.jujutsu.K48.com";
    notify yes;
    allow-transfer { 192.235.1.3; };
    also-notify   { 192.235.1.3; };
};
EOF

cat > /etc/bind/jujutsu/db.jujutsu.K48.com <<'EOF'
$TTL 604800
@   IN SOA ns1.jujutsu.K48.com. admin.jujutsu.K48.com. (
            2026101401 ; serial
            604800
            86400
            2419200
            604800 )
@   IN NS ns1.jujutsu.K48.com.
@   IN NS ns2.jujutsu.K48.com.
ns1 IN A 192.235.1.2
ns2 IN A 192.235.1.3
EOF

chown -R bind:bind /etc/bind/jujutsu
named-checkconf
named-checkzone jujutsu.K48.com /etc/bind/jujutsu/db.jujutsu.K48.com
service named restart || service bind9 restart