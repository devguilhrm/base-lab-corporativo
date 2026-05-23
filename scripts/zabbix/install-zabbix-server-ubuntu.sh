#!/usr/bin/env bash
# Install Zabbix Server 7.x with PostgreSQL 16 on Ubuntu Server 22.04.

set -euo pipefail

ZABBIX_DB_NAME="${ZABBIX_DB_NAME:-zabbix}"
ZABBIX_DB_USER="${ZABBIX_DB_USER:-zabbix}"
ZABBIX_DB_PASSWORD="${ZABBIX_DB_PASSWORD:-}"
ZABBIX_SERVER_CONF="${ZABBIX_SERVER_CONF:-/etc/zabbix/zabbix_server.conf}"

if [[ -z "$ZABBIX_DB_PASSWORD" ]]; then
  echo "Set ZABBIX_DB_PASSWORD before running this script." >&2
  exit 2
fi

sudo apt update
sudo apt install -y curl gnupg wget lsb-release

curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc |
  sudo gpg --dearmor -o /usr/share/keyrings/postgresql.gpg
echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" |
  sudo tee /etc/apt/sources.list.d/pgdg.list >/dev/null

sudo apt update
sudo apt install -y postgresql-16

sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='${ZABBIX_DB_USER}'" |
  grep -q 1 ||
  sudo -u postgres psql -c "CREATE USER ${ZABBIX_DB_USER} WITH PASSWORD '${ZABBIX_DB_PASSWORD}';"

sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='${ZABBIX_DB_NAME}'" |
  grep -q 1 ||
  sudo -u postgres psql -c "CREATE DATABASE ${ZABBIX_DB_NAME} OWNER ${ZABBIX_DB_USER} ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE template0;"

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${ZABBIX_DB_NAME} TO ${ZABBIX_DB_USER};"

wget -q https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb -O /tmp/zabbix-release.deb
sudo dpkg -i /tmp/zabbix-release.deb
sudo apt update
sudo apt install -y zabbix-server-pgsql zabbix-frontend-php php8.1-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent2

if ! sudo -u "$ZABBIX_DB_USER" psql "$ZABBIX_DB_NAME" -tAc "SELECT 1 FROM information_schema.tables WHERE table_name='users'" | grep -q 1; then
  zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u "$ZABBIX_DB_USER" psql "$ZABBIX_DB_NAME"
fi

sudo sed -i "s/^# DBPassword=.*/DBPassword=${ZABBIX_DB_PASSWORD}/" "$ZABBIX_SERVER_CONF"
sudo sed -i "s/^# DBHost=.*/DBHost=localhost/" "$ZABBIX_SERVER_CONF"
sudo sed -i "s/^DBName=.*/DBName=${ZABBIX_DB_NAME}/" "$ZABBIX_SERVER_CONF"
sudo sed -i "s/^DBUser=.*/DBUser=${ZABBIX_DB_USER}/" "$ZABBIX_SERVER_CONF"

sudo tee /etc/zabbix/zabbix_server.d/homelab-performance.conf >/dev/null <<'EOF'
StartPollers=10
StartTrappers=5
CacheSize=128M
HistoryCacheSize=64M
TrendCacheSize=32M
Timeout=30
AlertScriptsPath=/usr/lib/zabbix/alertscripts
ExternalScripts=/usr/lib/zabbix/externalscripts
EOF

sudo systemctl enable --now zabbix-server zabbix-agent2 nginx php8.1-fpm
sudo systemctl restart zabbix-server zabbix-agent2 nginx php8.1-fpm

echo "Zabbix Server installation finished."

