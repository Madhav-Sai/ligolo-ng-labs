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

Enterprise-style lab is up. This is the companion environment for course/16-capstone/.
Four networks: dmz_net -> internal_net (branches to db-server) -> restricted_net
(branches to mgmt-server) -> deep_net -> final-target.

Run ./verify.sh before you start.
EOF
