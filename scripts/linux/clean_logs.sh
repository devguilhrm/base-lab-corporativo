#!/usr/bin/env bash
# Remove old logs when a Zabbix disk usage trigger fires.

set -euo pipefail

LOG_FILE="${LOG_FILE:-/var/log/zabbix/auto_remediation.log}"
TARGET_DIR="${TARGET_DIR:-/var/log}"
DAYS_OLD="${DAYS_OLD:-30}"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

mkdir -p "$(dirname "$LOG_FILE")"

BEFORE="$(df -h / | awk 'NR==2 {print $5}')"
echo "[$TIMESTAMP] Starting log cleanup. Current root usage: $BEFORE" >> "$LOG_FILE"

find "$TARGET_DIR" -name "*.gz" -type f -mtime +"$DAYS_OLD" -delete
find "$TARGET_DIR" -name "*.1" -type f -mtime +"$DAYS_OLD" -delete

if command -v journalctl >/dev/null 2>&1; then
  journalctl --vacuum-time=7d
fi

AFTER="$(df -h / | awk 'NR==2 {print $5}')"
echo "[$TIMESTAMP] Log cleanup finished. Previous usage: $BEFORE | Current usage: $AFTER" >> "$LOG_FILE"

