# Templates Zabbix

Diretorio para templates customizados alinhados ao roadmap.

## Templates esperados

- `zabbix/templates/template-active-directory.yaml`
- `zabbix/templates/template-file-server.yaml`
- `zabbix/templates/template-linux-security.yaml`

## Itens sugeridos para `template-linux-security`

- `security.ssh.failed[10]`
- `security.fileintegrity.changes`
- `security.ssl.daysleft[host,443]`
- `security.ssh.failures`
- `security.fail2ban.banned`
- `system.updates.pending`

Arquivo base de UserParameter:

- `zabbix/userparameters/userparameter_security.conf`
- `zabbix/agent/linux/userparameter_security.conf`
