#!/usr/bin/env bash
# Weekly report runner for cron. Generates markdown summary from Zabbix API using Go.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

OUTPUT_DIR="${OUTPUT_DIR:-${ROOT_DIR}/reports/output}"
ZABBIX_URL="${ZABBIX_URL:-http://localhost:8080/api_jsonrpc.php}"
ZABBIX_USER="${ZABBIX_USER:-Admin}"
ZABBIX_PASSWORD="${ZABBIX_PASSWORD:-zabbix}"

mkdir -p "$OUTPUT_DIR"

go run "${ROOT_DIR}/cmd/weekly-report" \
  --zabbix-url "$ZABBIX_URL" \
  --zabbix-user "$ZABBIX_USER" \
  --zabbix-password "$ZABBIX_PASSWORD" \
  --output-dir "$OUTPUT_DIR"
