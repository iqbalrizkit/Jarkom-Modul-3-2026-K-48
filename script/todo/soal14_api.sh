#!/bin/bash
GETO_IP=192.235.4.5
DB_IP=192.235.4.3

echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update && apt-get install -y nginx php-fpm php-mysql curl
PHPV=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

mkdir -p /var/www/api
cat > /var/www/api/index.php <<'EOF'
<?php
header('Content-Type: application/json');
$host   = gethostname();
$remote = $_SERVER['REMOTE_ADDR'];

// hanya header dari geto yang dipercaya
$trusted_proxy = ['__GETO_IP__'];
$client_ip = $remote;
if (in_array($remote, $trusted_proxy) && !empty($_SERVER['HTTP_X_REAL_IP'])
    && filter_var($_SERVER['HTTP_X_REAL_IP'], FILTER_VALIDATE_IP)) {
    $client_ip = $_SERVER['HTTP_X_REAL_IP'];
}

$status = 'ok';
mysqli_report(MYSQLI_REPORT_OFF);
$db = @new mysqli('__DB_IP__', 'shibuya', 'shibuya123', 'db_shibuya_K48');
if ($db->connect_errno) {
    $status = 'db_error';
} else {
    $path = $_SERVER['REQUEST_URI'];
    $st = $db->prepare("INSERT INTO request_logs (hostname, client_ip, path) VALUES (?,?,?)");
    $st->bind_param('sss', $host, $client_ip, $path);
    $st->execute();
}
echo json_encode(['worker' => $host, 'client_ip' => $client_ip, 'status' => $status]);
EOF
sed -i "s/__GETO_IP__/$GETO_IP/; s/__DB_IP__/$DB_IP/" /var/www/api/index.php

cat > /etc/nginx/sites-available/api <<'EOF'
server {
    listen 80 default_server;
    server_name jujutsu.K48.com www.jujutsu.K48.com;
    root /var/www/api;

    # hanya menerima trafik dari geto (load balancer)
    allow __GETO_IP__;
    allow 127.0.0.1;
    deny all;

    location / {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root/index.php;
        fastcgi_pass unix:/run/php/php__PHPV__-fpm.sock;
    }
}
EOF
sed -i "s/__GETO_IP__/$GETO_IP/; s/__PHPV__/$PHPV/" /etc/nginx/sites-available/api

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/api /etc/nginx/sites-enabled/api

service php${PHPV}-fpm restart
nginx -t && service nginx restart