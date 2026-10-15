#!/bin/bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update && apt-get install -y mariadb-server mariadb-client

[ -d /var/lib/mysql/mysql ] || mariadb-install-db --user=mysql --datadir=/var/lib/mysql

mkdir -p /var/log/mysql && chown mysql:mysql /var/log/mysql
cat > /etc/mysql/mariadb.conf.d/99-shibuya.cnf <<'EOF'
[mysqld]
bind-address = 0.0.0.0
server-id    = 2
relay-log    = /var/log/mysql/relay-bin
skip-name-resolve
EOF

service mariadb restart || service mysql restart
for i in $(seq 1 30); do
  mariadb -e "SELECT 1" >/dev/null 2>&1 && break
  sleep 1
done

# MASTER_LOG_FILE = binlog PERTAMA dari "SHOW BINARY LOGS" di yaga
# MASTER_LOG_POS=4 supaya CREATE DATABASE/TABLE di Master ikut tereplikasi
mariadb <<'EOF'
STOP SLAVE;
CHANGE MASTER TO
  MASTER_HOST='192.235.4.3',
  MASTER_USER='repl',
  MASTER_PASSWORD='repl123',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=4;
START SLAVE;
EOF

sleep 3
mariadb -e "SHOW SLAVE STATUS\G" | grep -E "Master_Host|Slave_IO_Running|Slave_SQL_Running|Last_.*Error|Seconds_Behind"