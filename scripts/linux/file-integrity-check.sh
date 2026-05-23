#!/usr/bin/env bash
# Track checksum changes on critical files and return change count.

set -euo pipefail

BASELINE_FILE="${BASELINE_FILE:-/var/lib/lab/checksum-baseline.sha256}"
TARGETS_FILE="${TARGETS_FILE:-/etc/lab-checksum-targets.txt}"
WORK_FILE="$(mktemp)"

if [[ ! -f "$TARGETS_FILE" ]]; then
  echo "Targets file not found: $TARGETS_FILE" >&2
  exit 1
fi

while IFS= read -r path; do
  [[ -z "$path" || "$path" =~ ^# ]] && continue
  if [[ -f "$path" ]]; then
    sha256sum "$path" >> "$WORK_FILE"
  fi
done < "$TARGETS_FILE"

mkdir -p "$(dirname "$BASELINE_FILE")"

if [[ ! -f "$BASELINE_FILE" ]]; then
  mv "$WORK_FILE" "$BASELINE_FILE"
  echo "0"
  exit 0
fi

CHANGES="$(diff -u "$BASELINE_FILE" "$WORK_FILE" | grep -cE '^[+-][0-9a-f]' || true)"
mv "$WORK_FILE" "$BASELINE_FILE"

echo "$CHANGES"

