# Runbook Operacional

## 1. Bootstrap da stack de monitoramento

```bash
cd infra
cp .env.example .env
docker compose pull
docker compose up -d
docker compose ps
```

## 2. Validacao de saude

```bash
curl -I http://localhost:8080
curl -I http://localhost:3000
docker compose logs --tail=100 zabbix-server
docker compose logs --tail=100 grafana
```

## 3. Deploy de scripts em Linux monitorado

```bash
sudo install -m 0755 scripts/linux/auto-remediate-service.sh /usr/local/bin/auto-remediate-service.sh
sudo install -m 0755 scripts/linux/backup-configs.sh /usr/local/bin/backup-configs.sh
sudo install -m 0755 scripts/linux/monitor-ssh-failures.sh /usr/local/bin/monitor-ssh-failures.sh
sudo install -m 0755 scripts/linux/check-ssl-expiry.sh /usr/local/bin/check-ssl-expiry.sh
sudo install -m 0755 scripts/linux/file-integrity-check.sh /usr/local/bin/file-integrity-check.sh
```

## 4. Cron jobs recomendados

```cron
# Auto-remediation every 5 minutes
*/5 * * * * root /usr/local/bin/auto-remediate-service.sh nginx

# Daily backup at 01:15
15 1 * * * root /usr/local/bin/backup-configs.sh

# Weekly report every Monday at 07:00
0 7 * * 1 automation /bin/bash /path/to/repo/scripts/linux/generate-weekly-report.sh
```

## 5. Integracao com Zabbix Agent 2

1. Copiar `zabbix/agent/linux/userparameter_security.conf` para `/etc/zabbix/zabbix_agent2.d/`.
2. Reiniciar o agente:

```bash
sudo systemctl restart zabbix-agent2
sudo systemctl status zabbix-agent2 --no-pager
```

## 6. Templates, actions e discovery Zabbix

Importar no frontend:

- `zabbix/templates/template-active-directory.yaml`
- `zabbix/templates/template-file-server.yaml`
- `zabbix/templates/template-linux-security.yaml`

Configurar conforme guias:

- `docs/zabbix-implementation.md`
- `zabbix/actions/auto-remediation.yaml`
- `zabbix/discovery/network-discovery.yaml`
- `zabbix/web-scenarios/web-scenarios.yaml`

## 7. Troubleshooting rapido

- Zabbix web indisponivel:
  - Verificar `docker compose logs zabbix-web`.
  - Confirmar conectividade com o banco (`postgres` healthy).
- Grafana sem dados do Zabbix:
  - Validar plugin instalado.
  - Revisar credenciais do datasource provisionado.
- Agente Linux offline:
  - Testar porta `10050` no host.
  - Verificar `Server` e `ServerActive` no `zabbix_agent2.conf`.
