# Mock Tools

O projeto tem um modo de simulacao para validar o fluxo em maquinas sem Docker, Ansible ou Bash/WSL funcional.

## Quando usar

Use em ambiente Windows local quando voce quer validar o repositorio, mas ainda nao instalou:

- Docker
- Ansible
- WSL com uma distribuicao Linux

## Como executar

PowerShell:

```powershell
$env:LAB_USE_MOCK_TOOLS = "1"
go run ./cmd/readiness-check
```

Atalho PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/mock-tools.ps1
```

Bash:

```bash
LAB_USE_MOCK_TOOLS=1 go run ./cmd/readiness-check
```

## O que o mock valida

Docker Compose:

- Servicos `postgres`, `zabbix-server`, `zabbix-web` e `grafana`
- Imagens esperadas
- Portas principais
- Volumes persistentes
- Variaveis obrigatorias em `.env.example`

Ansible:

- Inventario Linux
- Variaveis globais
- Playbook de baseline
- Playbook de Zabbix Agent 2
- Fragmentos criticos como `fail2ban`, `PasswordAuthentication no` e `ServerActive`

Bash/WSL:

- Scripts em `scripts/linux`
- Scripts em `scripts/zabbix`
- Shebang `#!/usr/bin/env bash`
- Strict mode `set -euo pipefail`
- Checagem simples de aspas balanceadas

## Limite importante

Mock nao sobe containers, nao executa playbooks e nao interpreta Bash como um shell real. Ele serve para validar contrato do repositorio e destravar desenvolvimento local. Para runtime real, rode sem `LAB_USE_MOCK_TOOLS`.
