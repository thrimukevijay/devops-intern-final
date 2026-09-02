#!/usr/bin/env bash
# Report the host details required by the assessment.
set -euo pipefail

printf 'User: %s (effective UID: %s)\n' "$(id -un)" "$(id -u)"
printf 'Hostname: %s\n' "$(hostname)"
printf 'Kernel: %s\n' "$(uname -r)"
printf 'Date: %s\n' "$(date -Iseconds)"
printf '\nDisk usage:\n'
df -h / || true
printf '\nMemory usage:\n'
if command -v free >/dev/null 2>&1; then
  free -h
elif command -v vm_stat >/dev/null 2>&1; then
  vm_stat
else
  printf 'Memory reporting utility not available.\n'
fi
printf '\nDocker daemon: '
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  printf 'running\n'
else
  printf 'unavailable or not running\n'
fi
