#!/bin/bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update && apt-get install -y bind9 bind9utils dnsutils

mkdir -p /var/lib/bind && chown bind:bind /var/lib/bind
cat > /etc/bind/named.conf.local <<'EOF'
zone "jujutsu.K48.com" {
    type slave;
    masters { 192.235.1.2; };
    file "/var/lib/bind/db.jujutsu.K48.com";
};
EOF

named-checkconf
service named restart || service bind9 restart