# Evidencias do Lab Controlado

Esta pasta organiza os registros usados para acompanhar a implantacao do laboratorio.
Ela separa dois tipos de material:

- Evidencias coletadas localmente: saidas reais geradas nesta maquina durante testes, instalacao de prerequisitos e diagnostico.
- Evidencias de referencia: modelos de saida de um ambiente funcional, usados como base de estudo e comparacao para futuras execucoes.

## Evidencias Coletadas Localmente

| Arquivo | Conteudo |
|---|---|
| `01-go-test.txt` | Execucao dos testes automatizados em Go. |
| `02-readiness-mock.txt` | Validacao estrutural usando ferramentas substitutas de desenvolvimento. |
| `03-readiness-real.txt` | Readiness real do ambiente local no momento da coleta. |
| `04-docker-version.txt` | Verificacao inicial do Docker no Windows. |
| `06-ansible-version.txt` | Verificacao inicial do Ansible. |
| `07-go-version.txt` | Versao do Go instalada. |
| `09-wsl-ubuntu-install.txt` | Tentativa de instalacao do Ubuntu no WSL. |
| `10-enable-vmp.txt` | Tentativa inicial de habilitar Virtual Machine Platform. |
| `11-docker-desktop-install.txt` | Registro da instalacao do Docker Desktop via winget. |
| `12-windows-prereqs-install.txt` | Instalacao elevada dos prerequisitos do Windows. |
| `13-wsl-list-after-install.txt` | Lista WSL apos tentativa elevada. |
| `14-docker-version-after-install.txt` | Verificacao do Docker apos instalacao. |
| `15-wsl-status-after-install.txt` | Status WSL apos instalacao. |
| `16-windows-features-after-install.txt` | Estado dos recursos opcionais do Windows. |
| `17-virtualization-status.txt` | Estado da virtualizacao reportado pelo host. |
| `18-continue-after-reboot.txt` | Tentativa de continuidade apos reboot. |
| `19-fix-wsl-docker.txt` | Rotina de correcao WSL/Docker. |
| `20-wsl-list-after-fix.txt` | Lista WSL apos correcao. |
| `21-docker-version-after-fix.txt` | Verificacao do Docker apos correcao. |
| `22-readiness-real-after-fix.txt` | Readiness real apos correcao. |
| `23-docker-info-after-start.txt` | Diagnostico do Docker Desktop. |
| `24-repair-hypervisor-wsl.txt` | Diagnostico e ajuste dos recursos de hypervisor/WSL. |

## Evidencias de Referencia

Os arquivos em `referencia/` mostram como as evidencias devem se parecer quando o ambiente estiver operacional em Linux, WSL funcional ou VM VirtualBox.

Eles servem para:

- Estudar a ordem esperada de execucao.
- Comparar saidas futuras com uma referencia limpa.
- Documentar o comportamento alvo do laboratorio.
- Guiar prints, relatorios e validacoes quando o runtime estiver disponivel.

Arquivos principais:

| Arquivo | Conteudo |
|---|---|
| `01-go-test-ok.txt` | Testes Go passando. |
| `02-readiness-linux-ok.txt` | Readiness completo em ambiente Linux funcional. |
| `03-docker-compose-up.txt` | Subida da stack com Docker Compose. |
| `04-docker-compose-ps.txt` | Containers Zabbix, PostgreSQL e Grafana ativos. |
| `05-ansible-baseline.txt` | Playbook de baseline Linux aplicado. |
| `06-zabbix-agent-linux.txt` | Playbook de instalacao do Zabbix Agent 2 aplicado. |
| `07-endpoints-http.txt` | Endpoints Zabbix e Grafana respondendo. |
| `08-weekly-report.txt` | Exemplo de relatorio semanal via API do Zabbix. |

## Estado Atual

O repositorio esta estruturalmente pronto:

- Testes Go validam os artefatos essenciais.
- Docker Compose, Ansible, scripts Linux, dashboards e templates possuem contratos versionados.
- O Windows local apresentou bloqueio de WSL2/Hyper-V durante a tentativa de runtime.
- O caminho recomendado para execucao real agora e usar uma VM Linux no VirtualBox ou outro host Linux.

## Proxima Coleta Real

Quando o runtime Linux estiver disponivel, rode:

```bash
go test ./...
go run ./cmd/readiness-check
cd infra
cp .env.example .env
docker compose up -d
docker compose ps
```

Depois salve novas saidas nesta pasta com numeracao sequencial.
