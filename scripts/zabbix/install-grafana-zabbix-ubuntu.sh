#!/usr/bin/env bash
# Install Grafana OSS and the Zabbix datasource plugin on Ubuntu.

set -euo pipefail

sudo apt update
sudo apt install -y apt-transport-https software-properties-common wget gnupg

wget -q -O - https://apt.grafana.com/gpg.key |
  sudo gpg --dearmor -o /usr/share/keyrings/grafana.gpg
echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://apt.grafana.com stable main" |
  sudo tee /etc/apt/sources.list.d/grafana.list >/dev/null

sudo apt update
sudo apt install -y grafana
sudo grafana-cli plugins install alexanderzobnin-zabbix-app || true
sudo systemctl enable --now grafana-server
sudo systemctl restart grafana-server

echo "Grafana installed. Enable the Zabbix plugin and configure datasource URL http://localhost/zabbix."

