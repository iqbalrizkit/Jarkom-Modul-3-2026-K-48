#!/bin/bash
MAKI_IP=192.235.4.6
PANDA_IP=192.235.4.7
GETO_IP=192.235.4.5

echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update && apt-get install -y nginx curl

cat > /etc/nginx/sites-available/gojo <<'EOF'
upstream frontend_cluster {
    server __MAKI_IP__;     # maki
    server __PANDA_IP__;    # panda
}
server {
    listen 80 default_server;
    server_name jujutsu.K48.com www.jujutsu.K48.com;

    # /api -> internal load balancer (geto)
    location /api {
        proxy_pass http://__GETO_IP__;
        proxy_set_header Host $host;
    }

    # selain itu -> worker frontend (Round Robin)
    location / {
        proxy_pass http://frontend_cluster;
        proxy_set_header Host $host;
    }
}
EOF
sed -i "s/__MAKI_IP__/$MAKI_IP/; s/__PANDA_IP__/$PANDA_IP/; s/__GETO_IP__/$GETO_IP/" /etc/nginx/sites-available/gojo

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/gojo /etc/nginx/sites-enabled/gojo
nginx -t && service nginx restart