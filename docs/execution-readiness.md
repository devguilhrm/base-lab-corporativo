# Prontidao de Execucao

## Resultado local

Comando executado:

```bash
go test ./...
```

Resultado:

- Pacotes Go compilados
- Testes de prontidao aprovados

Comando executado:

```bash
go run ./cmd/readiness-check
```

Resultado nesta maquina:

- `OK` arquivos obrigatorios do projeto
- `OK` testes automatizados
- `WARN` Docker nao encontrado no `PATH`
- `WARN` Ansible nao encontrado no `PATH`
- `WARN` Bash/WSL nao consegue validar scripts shell aqui

Para validar o fluxo local com mocks:

```powershell
$env:LAB_USE_MOCK_TOOLS = "1"
go run ./cmd/readiness-check
```

Resultado esperado em modo mock:

- `OK` Docker Compose mock
- `OK` Ansible mock
- `OK` Bash/WSL mock

## Status por fase

| Fase | Status do repositorio | Status para execucao real |
|---|---|---|
| Fase 1 - Infraestrutura Base | Pronta como guia e baseline Ansible | Depende de Proxmox/VMs e Ansible |
| Fase 2 - AD e Windows Server | Documentada | Depende das VMs Windows e configuracao manual/PowerShell |
| Fase 3 - Zabbix Server | Compose, templates, UserParameters, actions e discovery prontos | Depende de Docker ou instalacao manual do Zabbix |
| Fase 4 - Grafana e Dashboards | Provisioning e dashboard inicial prontos | Depende do Grafana rodando e datasource autenticado |
| Fase 5 - Automacao e Seguranca | Scripts, actions e relatorio Go prontos | Depende de Bash/Linux real para `bash -n` e execucao |

## Criterio de "pronto para executar"

O projeto esta estruturalmente pronto. Para considerar o laboratorio 100% executavel em runtime, a maquina ou VM de operacao precisa ter:

- Docker com `docker compose`
- Ansible com `ansible-playbook`
- Bash funcional em Linux ou WSL instalado
- Go instalado para `go test`, `go run ./cmd/readiness-check` e relatorio semanal
- VMs e IPs alinhados ao `docs/architecture.md`
- Credenciais reais preenchidas em `infra/.env`
