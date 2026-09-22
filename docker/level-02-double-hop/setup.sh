#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

echo "[*] Building images..."
docker compose build

echo "[*] Starting containers..."
docker compose up -d

sleep 2
docker compose ps

cat <<'EOF'

Lab is up: kali -> pivot-01 -> pivot-02 -> internal-server-2 (restricted_net), plus
internal-server-1 hanging off pivot-01's own network for the first-hop recap.

Shells:
  docker compose exec kali bash
  docker compose exec pivot-01 bash
  docker compose exec pivot-02 bash

Follow course/08-second-hop/. Run ./verify.sh first.
EOF
