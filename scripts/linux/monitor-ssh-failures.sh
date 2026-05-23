#!/usr/bin/env bash
# Return failed SSH authentication count in the last N minutes.

set -euo pipefail

WINDOW_MINUTES="${1:-10}"

if command -v journalctl >/dev/null 2>&1; then
  COUNT="$(journalctl --since "-${WINDOW_MINUTES} min" -u ssh -u sshd 2>/dev/null | grep -Eci 'failed|invalid user' || true)"
else
  COUNT="$(grep -Eci 'Failed password|Invalid user' /var/log/auth.log 2>/dev/null || true)"
fi

echo "${COUNT:-0}"

