#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

docker compose down -v

if [ "${1:-}" = "--images" ]; then
  docker compose down --rmi local -v
fi

echo "[*] Lab reset."
