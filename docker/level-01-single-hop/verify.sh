#!/usr/bin/env bash
# Sanity-checks the level-01 lab: containers up, IPs correct, and - the important part -
# that the network is ACTUALLY segmented (kali cannot reach internal-server-1 yet).
# Run this right after setup.sh, before you've built any tunnel, to prove the lab isn't
# fake. Run it again after you've built the pivot to confirm the tunnel actually opened
# access that wasn't there before.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

pass=0
fail=0
ok()   { echo "  [PASS] $1"; pass=$((pass+1)); }
bad()  { echo "  [FAIL] $1"; fail=$((fail+1)); }

echo "== Containers running =="
for c in ligolo-lab01-kali ligolo-lab01-pivot01 ligolo-lab01-internal1; do
  if docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null | grep -q true; then
    ok "$c is running"
  else
    bad "$c is NOT running (did you run setup.sh?)"
  fi
done

echo "== IP addressing =="
# Checked by "does this IP exist anywhere on the container", not by a specific
# interface name - Docker doesn't guarantee eth0/eth1 ordering matches the order
# networks are listed in docker-compose.yml, so a pivot with two networks can come up
# as eth0=internal_net/eth1=attack_net just as easily as the reverse. This matches
# real life too: on a real pivot you don't already know which NIC is which until you
# look, per course/07-linux-pivot/02-finding-hidden-interfaces.md.
has_ip() {
  local container=$1 expected=$2
  if docker exec "$container" ip -4 -brief addr 2>/dev/null | awk '{print $3}' | cut -d/ -f1 | grep -qx "$expected"; then
    ok "$container has $expected on some interface"
  else
    bad "$container does NOT have $expected on any interface"
  fi
}
has_ip ligolo-lab01-kali      10.10.10.10
has_ip ligolo-lab01-pivot01   10.10.10.20
has_ip ligolo-lab01-pivot01   172.16.10.20
has_ip ligolo-lab01-internal1 172.16.10.50

echo "== Segmentation (this is the whole point of the lab) =="
if docker exec ligolo-lab01-kali ping -c1 -W2 172.16.10.50 >/dev/null 2>&1; then
  bad "kali can already reach 172.16.10.50 directly - segmentation is broken, the lab is not testing pivoting"
else
  ok "kali CANNOT reach internal-server-1 directly (expected - this is what the pivot fixes)"
fi

if docker exec ligolo-lab01-pivot01 ping -c1 -W2 172.16.10.50 >/dev/null 2>&1; then
  ok "pivot-01 CAN reach internal-server-1 (it's on internal_net, as expected)"
else
  bad "pivot-01 cannot reach internal-server-1 - internal_net is broken, fix docker-compose.yml"
fi

if docker exec ligolo-lab01-pivot01 ping -c1 -W2 10.10.10.10 >/dev/null 2>&1; then
  ok "pivot-01 CAN reach kali (attack_net side is up)"
else
  bad "pivot-01 cannot reach kali on attack_net"
fi

echo "== Ligolo-ng binaries present =="
docker exec ligolo-lab01-kali /usr/local/bin/proxy -version >/dev/null 2>&1 \
  && ok "proxy binary present on kali" || bad "proxy binary missing/broken on kali"
docker exec ligolo-lab01-pivot01 /usr/local/bin/agent -version >/dev/null 2>&1 \
  && ok "agent binary present on pivot-01" || bad "agent binary missing/broken on pivot-01"

echo
echo "$pass passed, $fail failed."
[ "$fail" -eq 0 ]
