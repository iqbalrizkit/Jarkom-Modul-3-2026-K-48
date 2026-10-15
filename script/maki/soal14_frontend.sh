#!/bin/bash
GOJO_IP=192.235.1.4

echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update && apt-get install -y nginx php-fpm curl
PHPV=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

mkdir -p /var/www/frontend
cat > /var/www/frontend/index.php <<'EOF'
<?php
echo "<h1>Frontend Worker: " . gethostname() . "</h1>\n";
EOF

cat > /etc/nginx/sites-available/frontend <<'EOF'
server {
    listen 80 default_server;
    server_name jujutsu.K48.com www.jujutsu.K48.com;
    root /var/www/frontend;
    index index.php;

    # hanya menerima trafik dari gojo (reverse proxy)
    allow __GOJO_IP__;
    allow 127.0.0.1;
    deny all;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php__PHPV__-fpm.sock;
    }
}
EOF
sed -i "s/__GOJO_IP__/$GOJO_IP/; s/__PHPV__/$PHPV/" /etc/nginx/sites-available/frontend

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/frontend /etc/nginx/sites-enabled/frontend

service php${PHPV}-fpm restart
nginx -t && service nginx restart