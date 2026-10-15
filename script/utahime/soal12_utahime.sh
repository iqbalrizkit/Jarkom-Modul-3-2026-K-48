#!/bin/bash
cat > /etc/bind/named.conf.local <<'EOF'
zone "jujutsu.K48.com" {
    type master;
    file "/etc/bind/jujutsu/db.jujutsu.K48.com";
    notify yes;
    allow-transfer { 192.235.1.3; };
    also-notify   { 192.235.1.3; };
};
zone "1.235.192.in-addr.arpa" {
    type master;
    file "/etc/bind/jujutsu/db.192.235.1";
    notify yes;
    allow-transfer { 192.235.1.3; };
    also-notify   { 192.235.1.3; };
};
EOF

cat > /etc/bind/jujutsu/db.jujutsu.K48.com <<'EOF'
$TTL 604800
@   IN SOA ns1.jujutsu.K48.com. admin.jujutsu.K48.com. (
            2026101403 ; serial
            604800
            86400
            2419200
            604800 )
@   IN NS ns1.jujutsu.K48.com.
@   IN NS ns2.jujutsu.K48.com.
ns1 IN A 192.235.1.2
ns2 IN A 192.235.1.3
@   IN A 192.235.1.4
www IN CNAME jujutsu.K48.com.
EOF

cat > /etc/bind/jujutsu/db.192.235.1 <<'EOF'
$TTL 604800
@   IN SOA ns1.jujutsu.K48.com. admin.jujutsu.K48.com. (
            2026101401 ; serial
            604800
            86400
            2419200
            604800 )
@   IN NS ns1.jujutsu.K48.com.
@   IN NS ns2.jujutsu.K48.com.
2   IN PTR ns1.jujutsu.K48.com.
3   IN PTR ns2.jujutsu.K48.com.
4   IN PTR jujutsu.K48.com.
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

chown -R bind:bind /etc/bind/jujutsu
named-checkconf
named-checkzone jujutsu.K48.com /etc/bind/jujutsu/db.jujutsu.K48.com
named-checkzone 1.235.192.in-addr.arpa /etc/bind/jujutsu/db.192.235.1
service named restart || service bind9 restart