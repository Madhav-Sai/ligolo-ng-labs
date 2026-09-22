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

Lab is up: kali -> pivot-01 -> pivot-02 -> pivot-03 -> critical-server, four networks
deep. Follow course/09-multi-hop/ (Scenario B). Run ./verify.sh first.
EOF
