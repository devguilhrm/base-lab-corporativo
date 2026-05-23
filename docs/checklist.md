# Checklist de Entregaveis

| Entregavel | Status inicial | Prioridade | Evidencia esperada |
|---|---|---|---|
| Proxmox instalado e VMs criadas | Pendente | Alta | Print e inventario de VMs |
| pfSense com VLANs configuradas | Pendente | Alta | Print interfaces/regras |
| Ubuntu Server (2 VMs) configurado | Pendente | Alta | `hostnamectl` + `ip a` |
| Rocky Linux (1 VM) configurado | Pendente | Media | `hostnamectl` + `ip a` |
| Windows 2022 com AD/DNS/DHCP | Pendente | Alta | Print ADUC e DNS |
| Windows File Server (DFS) | Pendente | Media | Print shares/DFS |
| Zabbix 7 instalado | Concluido (lab local) | Alta | `docker compose ps` |
| Hosts Linux no Zabbix | Parcial | Alta | Latest data em hosts Linux |
| Templates customizados AD/File Server/Linux Security | Concluido | Alta | YAML em `zabbix/templates/` |
| Alertas Telegram ativos | Pendente | Alta | Mensagem de teste |
| Grafana com datasource Zabbix | Concluido (bootstrap) | Alta | Datasource healthy |
| Dashboards Linux/Windows/Rede | Parcial | Alta | Prints dos paineis |
| Dashboard SLA e capacity | Pendente | Media | KPI SLA + forecast |
| Actions auto-remediacao Zabbix | Concluido | Media | `zabbix/actions/auto-remediation.yaml` |
| Scripts auto-remediacao | Concluido | Media | `restart_service.sh` e `clean_logs.sh` |
| Monitoramento seguranca SSH/RDP | Parcial | Alta | Linux pronto; RDP depende EventLog Windows |
| Documentacao GitHub publicada | Parcial | Alta | README final + evidencias |
