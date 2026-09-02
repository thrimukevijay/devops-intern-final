#!/usr/bin/env bash
# Verify that the application endpoint responds with HTTP 200.
set -euo pipefail

target_url="${1:-http://localhost:8080}"
case "$target_url" in
  */) health_url="${target_url}healthz" ;;
  *) health_url="${target_url}/healthz" ;;
esac

if command -v curl >/dev/null 2>&1; then
  status="$(curl --fail --silent --show-error --output /dev/null --write-out '%{http_code}' "$health_url" || true)"
elif command -v wget >/dev/null 2>&1; then
  if wget -q -O /dev/null "$health_url"; then status=200; else status=000; fi
else
  printf 'ERROR: curl or wget is required to check %s\n' "$health_url" >&2
  exit 127
fi

if [ "$status" = 200 ]; then
  printf 'OK: %s returned HTTP 200\n' "$health_url"
  exit 0
fi

printf 'ERROR: %s returned HTTP %s (expected 200)\n' "$health_url" "$status" >&2
exit 1
