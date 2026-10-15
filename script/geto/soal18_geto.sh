#!/bin/bash
GOJO_IP=192.235.1.4
NANAMI_IP=192.235.4.8
TODO_IP=192.235.4.9
KIRARA_IP=192.235.4.2

# format log: menunjukkan upstream yang dicoba tiap request
cat > /etc/nginx/conf.d/geto-log.conf <<'EOF'
log_format geto_log '$remote_addr [$time_local] "$request" status=$status ua=$upstream_addr us=$upstream_status rt=$request_time';
EOF

cat > /etc/nginx/sites-available/geto <<'EOF'
upstream api_cluster {
    server __NANAMI_IP__ weight=3 max_fails=2 fail_timeout=5s;   # nanami
    server __TODO_IP__   weight=1 max_fails=2 fail_timeout=5s;   # todo
    server __KIRARA_IP__ backup;                                 # kirara
}
server {
    listen 80 default_server;
    server_name jujutsu.K48.com;
    access_log /var/log/nginx/geto_access.log geto_log;

    set_real_ip_from __GOJO_IP__;
    real_ip_header   X-Real-IP;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;

        proxy_connect_timeout 2s;
        proxy_next_upstream error timeout http_502 http_503 http_504;
    }
}
EOF
sed -i "s/__GOJO_IP__/$GOJO_IP/; s/__NANAMI_IP__/$NANAMI_IP/; s/__TODO_IP__/$TODO_IP/; s/__KIRARA_IP__/$KIRARA_IP/" /etc/nginx/sites-available/geto

nginx -t && service nginx reload