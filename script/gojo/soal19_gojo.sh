#!/bin/bash
MAKI_IP=192.235.4.6
PANDA_IP=192.235.4.7
GETO_IP=192.235.4.5

mkdir -p /var/cache/nginx/frontend
chown -R www-data:www-data /var/cache/nginx

# zona cache, zona rate limit, dan format log (level http)
cat > /etc/nginx/conf.d/gojo-global.conf <<'EOF'
proxy_cache_path /var/cache/nginx/frontend levels=1:2 keys_zone=frontend_cache:10m max_size=100m inactive=10m use_temp_path=off;
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
log_format gojo_log '$remote_addr [$time_local] "$request" status=$status rt=$request_time ua=$upstream_addr us=$upstream_status cache=$upstream_cache_status';
EOF

cat > /etc/nginx/sites-available/gojo <<'EOF'
upstream frontend_cluster {
    server __MAKI_IP__;     # maki
    server __PANDA_IP__;    # panda
}
server {
    listen 80 default_server;
    server_name jujutsu.K48.com www.jujutsu.K48.com;
    access_log /var/log/nginx/gojo_access.log gojo_log;

    # API: rate limit 10 r/s per IP klien, tanpa cache
    location /api {
        limit_req zone=api_limit;
        limit_req_status 429;
        proxy_pass http://__GETO_IP__;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }

    # Web frontend: proxy cache 10 menit
    location / {
        proxy_pass http://frontend_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;

        proxy_cache frontend_cache;
        proxy_cache_valid 200 10m;
        proxy_cache_key "$scheme$host$request_uri";
        add_header X-Cache-Status $upstream_cache_status always;
    }
}
EOF
sed -i "s/__MAKI_IP__/$MAKI_IP/; s/__PANDA_IP__/$PANDA_IP/; s/__GETO_IP__/$GETO_IP/" /etc/nginx/sites-available/gojo

nginx -t && service nginx restart