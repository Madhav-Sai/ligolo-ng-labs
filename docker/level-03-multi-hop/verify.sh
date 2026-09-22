#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

pass=0; fail=0
ok()  { echo "  [PASS] $1"; pass=$((pass+1)); }
bad() { echo "  [FAIL] $1"; fail=$((fail+1)); }

echo "== Containers running =="
for c in kali pivot01 internal1 pivot02 internal2 pivot03 critical; do
  name="ligolo-lab03-$c"
  docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null | grep -q true \
    && ok "$name is running" || bad "$name is NOT running"
done

echo "== kali is isolated from everything past pivot-01 =="
for target in 172.16.10.50 192.168.50.10 10.20.20.100; do
  docker exec ligolo-lab03-kali ping -c1 -W2 "$target" >/dev/null 2>&1 \
    && bad "kali can already reach $target directly - segmentation broken" \
    || ok "kali cannot reach $target directly (expected)"
done

echo "== each hop only sees its own two networks =="
docker exec ligolo-lab03-pivot01 ping -c1 -W2 10.20.20.100 >/dev/null 2>&1 \
  && bad "pivot-01 can reach critical_net - far too much leaked" \
  || ok "pivot-01 cannot reach critical_net (expected)"
docker exec ligolo-lab03-pivot02 ping -c1 -W2 10.20.20.100 >/dev/null 2>&1 \
  && bad "pivot-02 can reach critical_net - should only be reachable via pivot-03" \
  || ok "pivot-02 cannot reach critical_net (expected)"

echo "== each hop CAN reach its own two networks =="
docker exec ligolo-lab03-pivot02 ping -c1 -W2 172.16.10.20 >/dev/null 2>&1 \
  && ok "pivot-02 can reach pivot-01 (internal_net)" || bad "pivot-02 cannot reach pivot-01"
docker exec ligolo-lab03-pivot02 ping -c1 -W2 192.168.50.40 >/dev/null 2>&1 \
  && ok "pivot-02 can reach pivot-03 (restricted_net)" || bad "pivot-02 cannot reach pivot-03"
docker exec ligolo-lab03-pivot03 ping -c1 -W2 10.20.20.100 >/dev/null 2>&1 \
  && ok "pivot-03 can reach critical-server (critical_net)" || bad "pivot-03 cannot reach critical-server"

echo
echo "$pass passed, $fail failed."
[ "$fail" -eq 0 ]
