# Fases de Implementacao

## Fase 1 - Infraestrutura Base (Semanas 1-3)

- Provisionar Proxmox e criar VMs do laboratorio.
- Configurar VLANs no bridge e conectividade entre redes.
- Instalar pfSense e regras iniciais de firewall.
- Aplicar baseline Linux com Ansible:

```bash
ansible-galaxy collection install -r ansible/requirements.yml
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/linux-baseline.yml
```

## Fase 2 - Active Directory e Windows (Semanas 4-6)

- Promover `vm-dc01` para AD DS (`corp.local`).
- Configurar DNS/DHCP integrados.
- Criar GPOs basicas de seguranca.
- Ingressar Linux no dominio com `realmd`/`sssd`.

## Fase 3 - Zabbix Server (Semanas 7-9)

- Subir stack central:

```bash
cd infra
cp .env.example .env
docker compose up -d
```

- Instalar agentes Linux:

```bash
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/zabbix-agent-linux.yml
```

- Cadastrar hosts Windows e rede via UI/API do Zabbix.
- Importar templates customizados em `zabbix/templates/`.
- Aplicar UserParameters Linux/Windows em `zabbix/agent/`.

## Fase 4 - Grafana e Dashboards (Semanas 10-11)

- Grafana sobe no `docker-compose` com plugin Zabbix.
- Ajustar datasource provisionado (`infra/grafana/provisioning/datasources/datasource.yml`).
- Importar dashboards oficiais e customizar:
  - Linux health
  - AD health
  - Rede SNMP
  - SLA e uptime
  - Capacity planning

## Fase 5 - Automacao e Seguranca (Semanas 12-14)

- Remediacao automatica:

```bash
sudo bash scripts/linux/auto-remediate-service.sh nginx
```

- Backup de configuracoes:

```bash
sudo bash scripts/linux/backup-configs.sh
```

- Monitoramento de seguranca:
  - `scripts/linux/monitor-ssh-failures.sh`
  - `scripts/linux/file-integrity-check.sh`
  - `scripts/linux/check-ssl-expiry.sh`

- Relatorio semanal:

```bash
bash scripts/linux/generate-weekly-report.sh
```

- Actions e auto-remediacao:

```bash
sudo install -m 0755 scripts/linux/restart_service.sh /usr/local/bin/restart_service.sh
sudo install -m 0755 scripts/linux/clean_logs.sh /usr/local/bin/clean_logs.sh
```

## Fase Final - Revisao e publicacao (Semanas 15-16)

- Executar checklist completo (`docs/checklist.md`).
- Gerar evidencias (prints, logs, relatorios).
- Publicar README final com resultados do laboratorio.
