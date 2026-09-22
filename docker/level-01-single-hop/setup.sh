#!/usr/bin/env bash
# Builds and starts the level-01 single-hop lab.
#
# Topology this brings up:
#   kali (10.10.10.10)  -- attack_net (10.10.10.0/24) --  pivot-01 (10.10.10.20 / 172.16.10.20)
#                                                                |
#                                             internal_net (172.16.10.0/24, no internet route)
#                                                                |
#                                            internal-server-1 (172.16.10.50)
#
# internal_net is marked "internal: true" in docker-compose.yml, so Docker itself
# refuses to route it anywhere except between containers attached to it. kali is not
# attached to internal_net at all. That's what makes this a real segmented lab instead
# of a fake one - there is no path from kali to internal-server-1 until a tunnel exists.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

echo "[*] Building images (this pulls ~0.9.1 ligolo-ng release binaries at build time, needs internet)..."
docker compose build

echo "[*] Starting containers..."
docker compose up -d

echo "[*] Waiting for containers to report healthy..."
sleep 2
docker compose ps

cat <<'EOF'

Lab is up. Next steps:

  1. Open a shell on kali:
       docker compose exec kali bash

  2. Open a shell on pivot-01 (in a second terminal):
       docker compose exec pivot-01 bash

  3. Follow course/05-single-hop/ in the main course, or run ./verify.sh first to
     confirm the lab is segmented correctly before you start.

Run ./reset.sh when you're done or want a clean slate.
EOF
