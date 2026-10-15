#!/bin/bash
NANAMI_IP=192.235.4.8
TODO_IP=192.235.4.9

echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update && apt-get install -y nginx curl

cat > /etc/nginx/sites-available/geto <<'EOF'
upstream api_cluster {
    server __NANAMI_IP__ weight=3;   # nanami
    server __TODO_IP__   weight=1;   # todo
}
server {
    listen 80 default_server;
    server_name jujutsu.K48.com;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
    }
}
EOF
sed -i "s/__NANAMI_IP__/$NANAMI_IP/; s/__TODO_IP__/$TODO_IP/" /etc/nginx/sites-available/geto

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/geto /etc/nginx/sites-enabled/geto
nginx -t && service nginx restart