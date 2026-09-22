#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
docker compose down -v
[ "${1:-}" = "--images" ] && docker compose down --rmi local -v
echo "[*] Lab reset."
