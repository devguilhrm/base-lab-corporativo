# Lab-controlado

Laboratório de infraestrutura corporativa criado para demonstrar, praticar e documentar competências reais de administração de sistemas, redes, monitoramento, automação e operação.

Este projeto não é apenas uma coleção de arquivos de configuração. Ele foi pensado como um ambiente técnico completo, com arquitetura, roadmap, validações, automações e documentação, simulando um pequeno cenário corporativo com Linux, Windows Server, Active Directory, pfSense, Zabbix, Grafana e PostgreSQL.

## O Que Este Projeto Faz

O Lab-controlado modela um ambiente de TI com servidores, rede segmentada, monitoramento centralizado, dashboards, alertas, inventário, discovery e respostas automatizadas a incidentes comuns.

Na prática, o projeto entrega:

- Uma stack central de monitoramento com Zabbix 7.x, PostgreSQL 16 e Grafana 11.
- Templates Zabbix customizados para Active Directory, File Server e segurança Linux.
- UserParameters para coletar métricas específicas em Linux e Windows.
- Automações de remediação para serviços parados e uso elevado de disco.
- Discovery, autoregistration, LLD e web scenarios para ampliar a cobertura operacional.
- Playbooks Ansible para baseline Linux e instalação do Zabbix Agent 2.
- Scripts de instalação para Zabbix Server, Grafana e Zabbix Agent Windows.
- Ferramentas em Go para readiness check e relatório semanal via API do Zabbix.
- Documentação técnica para execução, evolução e apresentação como portfólio.

## Por Que Ele Foi Pensado Assim

O objetivo foi construir um projeto com aparência e profundidade de trabalho real de infraestrutura: não apenas subir uma ferramenta, mas pensar no ciclo completo de operação.

As decisões principais foram:

- Separar infraestrutura, automação, monitoramento e documentação em camadas claras.
- Versionar artefatos que normalmente ficam perdidos em interfaces gráficas, como templates, actions, media types e discovery.
- Validar o repositório com testes automatizados para evitar regressões em arquivos críticos.
- Usar Go para ferramentas auxiliares, reduzindo dependências locais e facilitando a distribuição.
- Manter scripts Bash e PowerShell para operações próximas do ambiente real.
- Criar um modo mock para desenvolvimento em Windows, sem esconder que o runtime real depende de Docker, Ansible e Linux/WSL.

## Pontos Fortes

| Área | Destaque |
|---|---|
| Monitoramento | Zabbix estruturado com templates, agents, SNMP, web checks e alertas |
| Observabilidade | Grafana provisionado com datasource Zabbix e base para dashboards executivos |
| Automação | Ansible para baseline e agentes, Bash para remediação, Go para validação e relatórios |
| Segurança | Monitoramento de SSH, fail2ban, checksums de arquivos sensíveis e eventos Windows |
| Redes | pfSense, VLANs, SNMP, discovery e monitoramento de interfaces |
| Windows Server | Cobertura para AD, DNS, DHCP, File Server, DFS e serviços críticos |
| Linux | Baseline, hardening SSH, fail2ban, agentes e métricas customizadas |
| Portfólio | Documentação organizada, roadmap por fases e evidências técnicas versionáveis |
| Qualidade | Testes automatizados em Go e readiness check com modo real e modo mock |

## Arquitetura Proposta

| Host | Sistema | Papel no laboratório |
|---|---|---|
| `vm-zabbix` | Ubuntu Server 22.04 | Zabbix Server, PostgreSQL, Grafana |
| `vm-dc01` | Windows Server 2022 | Active Directory, DNS, DHCP |
| `vm-fs01` | Windows Server 2022 | File Server, DFS |
| `vm-linux01` | Ubuntu Server 22.04 | Servidor Linux monitorado |
| `vm-linux02` | Rocky Linux 9 | Web server monitorado |
| `vm-pfsense` | pfSense 2.7 | Gateway, firewall, SNMP |

Rede sugerida:

- Rede principal: `192.168.10.0/24`
- VLAN 10 Linux: `10.10.10.0/24`
- VLAN 20 Windows: `10.10.20.0/24`
- VLAN 99 Management: `10.10.99.0/24`

Mais detalhes em [architecture.md](C:/Users/PICHAU/Documents/PROJETOS/Lab-controlado/docs/architecture.md).

## Stack Técnica

| Camada | Tecnologia |
|---|---|
| Virtualização | Proxmox VE 8.x |
| Linux | Ubuntu Server 22.04, Rocky Linux 9 |
| Windows | Windows Server 2022, AD DS, DNS, DHCP, File Server |
| Monitoramento | Zabbix Server 7.x, Zabbix Agent 2 |
| Banco de dados | PostgreSQL 16 |
| Dashboards | Grafana OSS 11.x, plugin Zabbix |
| Rede | pfSense 2.7, VLANs, SNMP v2c/v3 |
| Automação | Ansible, Bash, PowerShell, Go |
| Validação | Go tests, readiness check e mock tools |

## Implementações Zabbix

O projeto transforma o planejamento Zabbix em artefatos reutilizáveis e versionados.

Inclui:

- Templates customizados em `zabbix/templates/`.
- UserParameters Linux e Windows em `zabbix/agent/`.
- Actions de auto-remediação em `zabbix/actions/`.
- Discovery, autoregistration e LLD em `zabbix/discovery/`.
- Web scenarios em `zabbix/web-scenarios/`.
- Media types e webhook em `zabbix/media/`.
- Scripts de instalação em `scripts/zabbix/`.

Guia completo em [zabbix-implementation.md](C:/Users/PICHAU/Documents/PROJETOS/Lab-controlado/docs/zabbix-implementation.md).

## Automação e Operação

O laboratório foi desenhado para exercitar tarefas comuns de uma operação de infraestrutura:

- Instalar e padronizar servidores Linux.
- Configurar agentes de monitoramento.
- Detectar serviços indisponíveis.
- Remediar falhas simples automaticamente.
- Coletar sinais de segurança.
- Gerar relatórios semanais via API.
- Validar se o projeto ainda está consistente antes de executar.

Ferramentas principais:

- `ansible/playbooks/linux-baseline.yml`
- `ansible/playbooks/zabbix-agent-linux.yml`
- `scripts/linux/restart_service.sh`
- `scripts/linux/clean_logs.sh`
- `cmd/readiness-check`
- `cmd/weekly-report`

## Modo Mock e Substituição Obrigatória

Este repositório inclui mocks para Docker, Ansible e Bash/WSL.

Eles existem para permitir que o projeto seja validado em uma máquina Windows mesmo quando a stack real ainda não está instalada. O mock valida contratos do repositório, como estrutura do Compose, presença de playbooks, fragmentos críticos e scripts esperados.

O mock não executa o laboratório real.

Antes de considerar o lab funcional, substitua os mocks por ferramentas reais:

- Docker Desktop ou Docker Engine para subir `infra/docker-compose.yml`.
- Ansible instalado em Linux/WSL para executar os playbooks.
- WSL com uma distribuição Linux ou outro ambiente Bash real para validar e executar scripts.

Executar readiness em modo mock:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/mock-tools.ps1
```

Executar readiness real:

```bash
go run ./cmd/readiness-check
```

Documentação em [mock-tools.md](C:/Users/PICHAU/Documents/PROJETOS/Lab-controlado/docs/mock-tools.md).

## Como Testar Localmente no Windows

Validar a qualidade estrutural:

```powershell
go test ./...
```

Validar com mocks:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/mock-tools.ps1
```

Resultado esperado em modo mock:

```text
[OK] project files
[OK] automated tests
[OK] docker compose: Mock Docker Compose validation passed.
[OK] ansible: Mock Ansible syntax/contract validation passed.
[OK] bash scripts: Mock Bash/WSL validation passed.
```

## Execução Real do Laboratório

1. Criar arquivo de ambiente:

```bash
cp infra/.env.example infra/.env
```

2. Ajustar credenciais em `infra/.env`.

3. Subir Zabbix, PostgreSQL e Grafana:

```bash
cd infra
docker compose up -d
docker compose ps
```

4. Aplicar baseline Linux:

```bash
ansible-galaxy collection install -r ansible/requirements.yml
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/linux-baseline.yml
```

5. Instalar Zabbix Agent 2 nos Linux:

```bash
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/zabbix-agent-linux.yml
```

6. Importar templates Zabbix e configurar media types, discovery, actions e web scenarios.

## Estrutura do Repositório

```text
.
|-- ansible/               # Inventário, variáveis e playbooks
|-- cmd/                   # Ferramentas Go de operação
|-- docs/                  # Arquitetura, fases, runbook e prontidão
|-- infra/                 # Docker Compose Zabbix/PostgreSQL/Grafana
|-- internal/              # Cliente Zabbix API em Go
|-- scripts/               # Automações Bash, PowerShell e mock local
|-- templates/             # Referências de templates
|-- zabbix/                # Templates, UserParameters, actions, media, discovery
`-- project_readiness_test.go
```

## Roadmap

| Fase | Escopo | Status |
|---|---|---|
| Fase 1 | Infraestrutura base, Linux baseline, segurança SSH | Implementado |
| Fase 2 | AD, DNS, DHCP, File Server, integração Windows | Documentado e instrumentado |
| Fase 3 | Zabbix Server, agentes, templates, alertas | Implementado |
| Fase 4 | Grafana, datasource Zabbix, dashboards | Base implementada |
| Fase 5 | Automação, segurança, auto-remediação, relatórios | Implementado |

## Cuidados de Segurança

- Nunca versionar segredos reais.
- Alterar credenciais padrão no primeiro acesso.
- Usar `.env` local para senhas.
- Restringir Zabbix e Grafana por rede, VPN ou firewall.
- Preferir SNMPv3 fora de ambientes de laboratório.
- Revisar actions de auto-remediação antes de habilitar execução remota.

## Documentação Principal

- [architecture.md](C:/Users/PICHAU/Documents/PROJETOS/Lab-controlado/docs/architecture.md)
- [phases.md](C:/Users/PICHAU/Documents/PROJETOS/Lab-controlado/docs/phases.md)
- [runbook.md](C:/Users/PICHAU/Documents/PROJETOS/Lab-controlado/docs/runbook.md)
- [execution-readiness.md](C:/Users/PICHAU/Documents/PROJETOS/Lab-controlado/docs/execution-readiness.md)
- [mock-tools.md](C:/Users/PICHAU/Documents/PROJETOS/Lab-controlado/docs/mock-tools.md)
- [zabbix-implementation.md](C:/Users/PICHAU/Documents/PROJETOS/Lab-controlado/docs/zabbix-implementation.md)

