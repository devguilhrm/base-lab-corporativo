# Media Types

## E-mail SMTP

| Parametro | Valor |
|---|---|
| Type | E-mail |
| SMTP Server | smtp.gmail.com |
| SMTP Port | 587 |
| SMTP From | zabbix@seu-dominio.com |
| Authentication | Username + Password |
| Message format | HTML |

## Telegram Bot

Executar no `vm-zabbix`:

```bash
cd /usr/lib/zabbix/alertscripts
sudo wget https://raw.githubusercontent.com/zbx-sadman/alertscript-telegram/master/telegram.sh
sudo chmod +x telegram.sh
```

Criar no frontend:

- Type: Script
- Script name: `telegram.sh`
- Parameters: `{ALERT.SENDTO}`, `{ALERT.SUBJECT}`, `{ALERT.MESSAGE}`

## Slack ou Teams Webhook

Usar `zabbix/media/webhook-slack-teams.js` como base para um Media Type do tipo Webhook.

