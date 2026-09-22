#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

pass=0
fail=0
ok()  { echo "  [PASS] $1"; pass=$((pass+1)); }
bad() { echo "  [FAIL] $1"; fail=$((fail+1)); }

echo "== Containers running =="
for c in ligolo-lab02-kali ligolo-lab02-pivot01 ligolo-lab02-internal1 ligolo-lab02-pivot02 ligolo-lab02-internal2; do
  docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null | grep -q true \
    && ok "$c is running" || bad "$c is NOT running"
done

echo "== Segmentation: attack_net cannot see internal_net or restricted_net =="
docker exec ligolo-lab02-kali ping -c1 -W2 172.16.10.50 >/dev/null 2>&1 \
  && bad "kali can reach 172.16.10.50 directly - segmentation broken" \
  || ok "kali cannot reach internal-server-1 directly (expected)"
docker exec ligolo-lab02-kali ping -c1 -W2 192.168.50.10 >/dev/null 2>&1 \
  && bad "kali can reach 192.168.50.10 directly - segmentation broken" \
  || ok "kali cannot reach internal-server-2 directly (expected)"

echo "== Segmentation: internal_net cannot see restricted_net without pivot-02 =="
docker exec ligolo-lab02-pivot01 ping -c1 -W2 192.168.50.10 >/dev/null 2>&1 \
  && bad "pivot-01 can already reach 192.168.50.10 - restricted_net leaked into internal_net" \
  || ok "pivot-01 cannot reach restricted_net (expected - only pivot-02 straddles that boundary)"

echo "== Reachability that SHOULD work =="
docker exec ligolo-lab02-pivot01 ping -c1 -W2 172.16.10.50 >/dev/null 2>&1 \
  && ok "pivot-01 can reach internal-server-1" || bad "pivot-01 cannot reach internal-server-1 (internal_net broken)"
docker exec ligolo-lab02-pivot02 ping -c1 -W2 172.16.10.20 >/dev/null 2>&1 \
  && ok "pivot-02 can reach pivot-01 (internal_net)" || bad "pivot-02 cannot reach pivot-01"
docker exec ligolo-lab02-pivot02 ping -c1 -W2 192.168.50.10 >/dev/null 2>&1 \
  && ok "pivot-02 can reach internal-server-2 (restricted_net)" || bad "pivot-02 cannot reach internal-server-2"

echo "== Ligolo-ng binaries =="
docker exec ligolo-lab02-kali /usr/local/bin/proxy -version >/dev/null 2>&1 && ok "proxy present on kali" || bad "proxy missing on kali"
docker exec ligolo-lab02-kali /opt/ligolo/agent -version >/dev/null 2>&1 && ok "spare agent binary present on kali (for handing to pivot-02)" || bad "spare agent binary missing on kali"
docker exec ligolo-lab02-pivot01 /usr/local/bin/agent -version >/dev/null 2>&1 && ok "agent present on pivot-01" || bad "agent missing on pivot-01"
docker exec ligolo-lab02-pivot02 /usr/local/bin/agent -version >/dev/null 2>&1 && ok "agent present on pivot-02" || bad "agent missing on pivot-02"

echo
echo "$pass passed, $fail failed."
[ "$fail" -eq 0 ]
