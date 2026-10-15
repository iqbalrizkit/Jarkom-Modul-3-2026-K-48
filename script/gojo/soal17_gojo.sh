#!/bin/bash
MAKI_IP=192.235.4.6
PANDA_IP=192.235.4.7
GETO_IP=192.235.4.5

cat > /etc/nginx/sites-available/gojo <<'EOF'
upstream frontend_cluster {
    server __MAKI_IP__;     # maki
    server __PANDA_IP__;    # panda
}
server {
    listen 80 default_server;
    server_name jujutsu.K48.com www.jujutsu.K48.com;

    # gojo = proxy terluar, jadi header dari klien TIDAK dipercaya.
    # Header ditimpa dengan IP koneksi yang sebenarnya.
    location /api {
        proxy_pass http://__GETO_IP__;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }

    location / {
        proxy_pass http://frontend_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}
EOF
sed -i "s/__MAKI_IP__/$MAKI_IP/; s/__PANDA_IP__/$PANDA_IP/; s/__GETO_IP__/$GETO_IP/" /etc/nginx/sites-available/gojo

nginx -t && service nginx reload