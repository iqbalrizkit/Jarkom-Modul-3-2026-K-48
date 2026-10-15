#!/bin/bash
GOJO_IP=192.235.1.4
NANAMI_IP=192.235.4.8
TODO_IP=192.235.4.9

cat > /etc/nginx/sites-available/geto <<'EOF'
upstream api_cluster {
    server __NANAMI_IP__ weight=3;   # nanami
    server __TODO_IP__   weight=1;   # todo
}
server {
    listen 80 default_server;
    server_name jujutsu.K48.com;

    # Header IP klien hanya dipercaya kalau koneksi datang dari gojo.
    # Dari sumber lain, header X-Real-IP diabaikan.
    set_real_ip_from __GOJO_IP__;
    real_ip_header   X-Real-IP;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
        # $remote_addr di sini sudah IP klien yang terverifikasi
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}
EOF
sed -i "s/__GOJO_IP__/$GOJO_IP/; s/__NANAMI_IP__/$NANAMI_IP/; s/__TODO_IP__/$TODO_IP/" /etc/nginx/sites-available/geto

nginx -t && service nginx reload