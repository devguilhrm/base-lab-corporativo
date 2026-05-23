# Evidencias de Referencia

Este diretorio contem exemplos de saidas esperadas para um ambiente funcional do Lab Controlado.

Use estes arquivos como base de estudo e checklist visual. Eles nao substituem uma coleta real: quando o ambiente estiver rodando em Linux, WSL funcional ou VirtualBox, gere novas evidencias a partir dos comandos executados naquele host.

## Ambiente Alvo

- Ubuntu Server 22.04 ou 24.04.
- Docker Engine com Docker Compose plugin.
- Ansible instalado.
- Go instalado.
- Projeto em `~/Lab-controlado`.
- Stack em `infra/docker-compose.yml` ativa.

## Ordem Recomendada

1. Validar o repositorio com `go test ./...`.
2. Rodar `go run ./cmd/readiness-check`.
3. Criar `infra/.env`.
4. Subir a stack com `docker compose up -d`.
5. Conferir containers com `docker compose ps`.
6. Instalar collections Ansible.
7. Aplicar baseline e Zabbix Agent.
8. Validar endpoints HTTP.
9. Gerar relatorio semanal.
