# Implementacao Zabbix

Este documento resume os artefatos criados a partir do arquivo `implementacoes_zabbix.docx`.

## Server

O laboratorio mantem dois caminhos:

- Execucao rapida via Docker Compose em `infra/docker-compose.yml`.
- Instalacao manual em `vm-zabbix` conforme comandos do DOCX, usando Zabbix 7.x, PostgreSQL 16 e Grafana 11.

Scripts prontos:

- `scripts/zabbix/install-zabbix-server-ubuntu.sh`
- `scripts/zabbix/install-grafana-zabbix-ubuntu.sh`
- `scripts/zabbix/install-zabbix-agent-windows.ps1`

Exemplo de instalacao manual do servidor:

```bash
export ZABBIX_DB_PASSWORD='troque-esta-senha'
bash scripts/zabbix/install-zabbix-server-ubuntu.sh
bash scripts/zabbix/install-grafana-zabbix-ubuntu.sh
```

Parametros recomendados para `zabbix_server.conf`:

| Parametro | Valor |
|---|---|
| DBHost | localhost |
| DBName | zabbix |
| DBUser | zabbix |
| StartPollers | 10 |
| StartTrappers | 5 |
| CacheSize | 128M |
| HistoryCacheSize | 64M |
| TrendCacheSize | 32M |
| Timeout | 30 |
| AlertScriptsPath | /usr/lib/zabbix/alertscripts |
| ExternalScripts | /usr/lib/zabbix/externalscripts |

## Templates customizados

Importar no frontend do Zabbix em `Data collection > Templates > Import`:

- `zabbix/templates/template-active-directory.yaml`
- `zabbix/templates/template-file-server.yaml`
- `zabbix/templates/template-linux-security.yaml`

Templates nativos a aplicar:

- `Linux by Zabbix agent 2`
- `Windows by Zabbix agent`
- `pfSense by SNMP`
- `Network Generic Device SNMP`
- `PostgreSQL by Zabbix agent 2`
- `Nginx by Zabbix agent 2`

## UserParameters

Linux:

- `zabbix/agent/linux/userparameter_security.conf`
- `zabbix/userparameters/userparameter_security.conf`

Windows:

- `zabbix/agent/windows/userparameter_ad.conf`
- `zabbix/agent/windows/userparameter_fileserver.conf`

Depois de copiar os arquivos, reiniciar o agente:

```bash
sudo systemctl restart zabbix-agent2
```

No Windows:

```powershell
Restart-Service -Name 'Zabbix Agent 2'
```

## Actions e auto-remediacao

Artefatos:

- `zabbix/actions/auto-remediation.yaml`
- `scripts/linux/restart_service.sh`
- `scripts/linux/clean_logs.sh`

Instalar scripts no host Linux monitorado:

```bash
sudo install -m 0755 scripts/linux/restart_service.sh /usr/local/bin/restart_service.sh
sudo install -m 0755 scripts/linux/clean_logs.sh /usr/local/bin/clean_logs.sh
```

## Discovery e web checks

Artefatos:

- `zabbix/discovery/network-discovery.yaml`
- `zabbix/web-scenarios/web-scenarios.yaml`

Eles cobrem:

- Descoberta da rede `192.168.10.0/24`
- Auto-registro Linux e Windows
- LLD de filesystems, interfaces, servicos Windows e SNMP
- Web checks de Zabbix, Grafana, Nginx, pfSense e IIS opcional

## Alertas

Artefatos:

- `zabbix/media/media-types.md`
- `zabbix/media/webhook-slack-teams.js`

Configurar SMTP, Telegram e webhook no frontend do Zabbix.
