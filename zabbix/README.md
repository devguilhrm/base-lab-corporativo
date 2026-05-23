# Zabbix

Artefatos de implementacao do Zabbix 7.x para o homelab corporativo.

## Objetivo

Este diretorio concentra os arquivos que transformam o Zabbix em uma plataforma de monitoramento reutilizavel:

- Templates customizados para Windows, Linux e servicos corporativos.
- UserParameters para metricas que nao estao nos templates nativos.
- Actions de remediacao e resposta operacional.
- Discovery, autoregistration e web scenarios.
- Media types para notificacao.

## Ordem Sugerida

1. Subir Zabbix, PostgreSQL e Grafana pelo Compose em `infra/`.
2. Acessar o frontend do Zabbix em `http://localhost:8080`.
3. Instalar agentes Linux e Windows.
4. Copiar UserParameters para os hosts monitorados.
5. Importar templates customizados.
6. Configurar hosts e aplicar templates nativos.
7. Criar actions, discovery, autoregistration e web scenarios.
8. Configurar media types.
9. Validar alertas, dashboards e auto-remediacao.

## Diretorios

- `templates/`: templates customizados em YAML.
- `agent/`: UserParameters Linux e Windows.
- `actions/`: definicoes operacionais de actions.
- `discovery/`: discovery, autoregistration e LLD.
- `web-scenarios/`: cenarios HTTP/HTTPS.
- `media/`: e-mail, Telegram e webhook.

## Evidencias de Referencia

As saidas em `docs/evidencias/referencia/` servem como base de estudo para comparar o comportamento esperado do ambiente funcional.

Para esta camada, os arquivos mais uteis sao:

- `docs/evidencias/referencia/03-docker-compose-up.txt`
- `docs/evidencias/referencia/04-docker-compose-ps.txt`
- `docs/evidencias/referencia/06-zabbix-agent-linux.txt`
- `docs/evidencias/referencia/07-endpoints-http.txt`
- `docs/evidencias/referencia/08-weekly-report.txt`

Quando o ambiente real estiver disponivel, gere novas evidencias com os comandos executados no host Linux ou na VM.
