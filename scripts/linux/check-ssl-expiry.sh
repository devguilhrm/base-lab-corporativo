#!/usr/bin/env bash
# Check SSL certificate expiry for a host and return days until expiration.

set -euo pipefail

TARGET_HOST="${1:-localhost}"
TARGET_PORT="${2:-443}"

CERT_END_DATE="$(echo | openssl s_client -servername "$TARGET_HOST" -connect "${TARGET_HOST}:${TARGET_PORT}" 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)"

if [[ -z "$CERT_END_DATE" ]]; then
  echo "-1"
  exit 1
fi

END_EPOCH="$(date -d "$CERT_END_DATE" +%s)"
NOW_EPOCH="$(date +%s)"
DAYS_LEFT="$(( (END_EPOCH - NOW_EPOCH) / 86400 ))"

echo "$DAYS_LEFT"

