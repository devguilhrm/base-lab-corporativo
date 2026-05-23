#!/usr/bin/env bash
# Auto-remediation for Linux services triggered by cron or Zabbix action.

set -euo pipefail

SERVICE_NAME="${1:-nginx}"
MAX_RETRIES="${MAX_RETRIES:-2}"
SLEEP_BETWEEN_RETRIES="${SLEEP_BETWEEN_RETRIES:-5}"
LOG_FILE="${LOG_FILE:-/var/log/lab-auto-remediation.log}"

log() {
  local level="$1"
  local message="$2"
  printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$message" | tee -a "$LOG_FILE"
}

service_is_active() {
  systemctl is-active --quiet "$SERVICE_NAME"
}

restart_service() {
  log "WARN" "Service $SERVICE_NAME is down. Trying restart."
  systemctl restart "$SERVICE_NAME"
}

main() {
  if service_is_active; then
    log "INFO" "Service $SERVICE_NAME is healthy."
    exit 0
  fi

  for attempt in $(seq 1 "$MAX_RETRIES"); do
    restart_service
    sleep "$SLEEP_BETWEEN_RETRIES"

    if service_is_active; then
      log "INFO" "Service $SERVICE_NAME recovered on attempt $attempt."
      exit 0
    fi
  done

  log "ERROR" "Service $SERVICE_NAME did not recover after $MAX_RETRIES attempts."
  exit 1
}

main "$@"

