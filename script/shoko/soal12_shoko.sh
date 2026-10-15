#!/bin/bash
cat > /etc/bind/named.conf.local <<'EOF'
zone "jujutsu.K48.com" {
    type slave;
    masters { 192.235.1.2; };
    file "/var/lib/bind/db.jujutsu.K48.com";
};
zone "1.235.192.in-addr.arpa" {
    type slave;
    masters { 192.235.1.2; };
    file "/var/lib/bind/db.192.235.1";
};
EOF

cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    forward only;
    dnssec-validation no;
    allow-query { any; };
    allow-recursion { any; };
    listen-on { any; };
    listen-on-v6 { none; };
};
EOF

named-checkconf
service named restart || service bind9 restart