#!/usr/bin/env bash
# Restart a Linux service from a Zabbix action and record the result.

set -euo pipefail

SERVICE_NAME="${1:-}"
LOG_FILE="${LOG_FILE:-/var/log/zabbix/auto_remediation.log}"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

if [[ -z "$SERVICE_NAME" ]]; then
  echo "[$TIMESTAMP] Missing service name." | tee -a "$LOG_FILE" >&2
  exit 2
fi

mkdir -p "$(dirname "$LOG_FILE")"
echo "[$TIMESTAMP] Trying to restart service: $SERVICE_NAME" >> "$LOG_FILE"

if systemctl is-active --quiet "$SERVICE_NAME"; then
  echo "[$TIMESTAMP] Service $SERVICE_NAME is already active." >> "$LOG_FILE"
  exit 0
fi

systemctl restart "$SERVICE_NAME"
sleep 5

if systemctl is-active --quiet "$SERVICE_NAME"; then
  echo "[$TIMESTAMP] Service $SERVICE_NAME restarted successfully." >> "$LOG_FILE"
  exit 0
fi

echo "[$TIMESTAMP] Failed to restart $SERVICE_NAME. Manual intervention required." >> "$LOG_FILE"
exit 1

