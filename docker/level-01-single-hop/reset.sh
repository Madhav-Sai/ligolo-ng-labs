#!/usr/bin/env bash
# Tears the lab down completely: containers, networks, and (with --images) the built
# images too, so the next setup.sh is a genuinely clean run.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

docker compose down -v

if [ "${1:-}" = "--images" ]; then
  echo "[*] Removing built images too..."
  docker compose down --rmi local -v
fi

echo "[*] Lab reset. Run ./setup.sh to bring it back up."
