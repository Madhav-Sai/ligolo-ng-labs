#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

pass=0; fail=0
ok()  { echo "  [PASS] $1"; pass=$((pass+1)); }
bad() { echo "  [FAIL] $1"; fail=$((fail+1)); }

echo "== Containers running =="
for c in kali pivot-dmz db-server pivot-internal mgmt-server pivot-restricted final-target; do
  name="ligolo-lab04-$c"
  docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null | grep -q true \
    && ok "$name is running" || bad "$name is NOT running"
done

echo "== kali starts isolated past the DMZ =="
for target in 10.50.20.50 10.50.30.40 10.50.40.100; do
  docker exec ligolo-lab04-kali ping -c1 -W2 "$target" >/dev/null 2>&1 \
    && bad "kali can already reach $target - segmentation broken" \
    || ok "kali cannot reach $target directly (expected)"
done

echo "== branch isolation =="
docker exec ligolo-lab04-pivot-dmz ping -c1 -W2 10.50.30.40 >/dev/null 2>&1 \
  && bad "pivot-dmz can reach restricted_net - too much leaked" \
  || ok "pivot-dmz cannot reach restricted_net (expected - only pivot-internal bridges that)"
docker exec ligolo-lab04-pivot-internal ping -c1 -W2 10.50.40.100 >/dev/null 2>&1 \
  && bad "pivot-internal can reach deep_net - too much leaked" \
  || ok "pivot-internal cannot reach deep_net (expected - only pivot-restricted bridges that)"

echo "== expected reachability at each hop =="
docker exec ligolo-lab04-pivot-dmz ping -c1 -W2 10.50.20.50 >/dev/null 2>&1 \
  && ok "pivot-dmz can reach db-server (internal_net)" || bad "pivot-dmz cannot reach db-server"
docker exec ligolo-lab04-pivot-internal ping -c1 -W2 10.50.30.40 >/dev/null 2>&1 \
  && ok "pivot-internal can reach mgmt-server (restricted_net)" || bad "pivot-internal cannot reach mgmt-server"
docker exec ligolo-lab04-pivot-restricted ping -c1 -W2 10.50.40.100 >/dev/null 2>&1 \
  && ok "pivot-restricted can reach final-target (deep_net)" || bad "pivot-restricted cannot reach final-target"

echo
echo "$pass passed, $fail failed."
[ "$fail" -eq 0 ]
