#!/usr/bin/env bash
# Backup critical configuration files and send to a local/remote path.

set -euo pipefail

SOURCE_PATHS="${SOURCE_PATHS:-/etc /var/spool/cron}"
BACKUP_ROOT="${BACKUP_ROOT:-/var/backups/lab}"
RETENTION_DAYS="${RETENTION_DAYS:-15}"
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
HOSTNAME_SHORT="$(hostname -s)"
ARCHIVE_NAME="${HOSTNAME_SHORT}_configs_${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_ROOT"

tar -czf "${BACKUP_ROOT}/${ARCHIVE_NAME}" $SOURCE_PATHS
find "$BACKUP_ROOT" -type f -name "*_configs_*.tar.gz" -mtime +"$RETENTION_DAYS" -delete

echo "Backup created: ${BACKUP_ROOT}/${ARCHIVE_NAME}"

