#!/bin/bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update && apt-get install -y mariadb-server mariadb-client

# jaga-jaga kalau datadir belum terinisialisasi
[ -d /var/lib/mysql/mysql ] || mariadb-install-db --user=mysql --datadir=/var/lib/mysql

mkdir -p /var/log/mysql && chown mysql:mysql /var/log/mysql
cat > /etc/mysql/mariadb.conf.d/99-shibuya.cnf <<'EOF'
[mysqld]
bind-address = 0.0.0.0
server-id    = 1
log_bin      = /var/log/mysql/mysql-bin.log
skip-name-resolve
EOF

service mariadb restart || service mysql restart
for i in $(seq 1 30); do
  mariadb -e "SELECT 1" >/dev/null 2>&1 && break
  sleep 1
done

mariadb <<'EOF'
CREATE DATABASE IF NOT EXISTS db_shibuya_K48;
USE db_shibuya_K48;
CREATE TABLE IF NOT EXISTS request_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  hostname VARCHAR(64),
  client_ip VARCHAR(45),
  path VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE USER IF NOT EXISTS 'repl'@'192.235.4.%'    IDENTIFIED BY 'repl123';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.235.4.%';
CREATE USER IF NOT EXISTS 'shibuya'@'192.235.4.%' IDENTIFIED BY 'shibuya123';
GRANT ALL PRIVILEGES ON db_shibuya_K48.* TO 'shibuya'@'192.235.4.%';
FLUSH PRIVILEGES;
EOF

mariadb -e "SHOW MASTER STATUS; SHOW BINARY LOGS;"