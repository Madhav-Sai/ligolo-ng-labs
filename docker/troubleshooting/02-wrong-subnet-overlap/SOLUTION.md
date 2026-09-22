# Solution — Broken Lab 02

`docker compose up` fails with something like:

```
Error response from daemon: Pool overlaps with other one on this address space
```

The fix is the one-line change back to the correct topology:

```yaml
internal_net:
  ipam: { config: [{ subnet: 172.16.10.0/24 }] }
```

and the corresponding container IPs (`172.16.10.20` for pivot-01's second interface,
`172.16.10.50` for internal-server-1).

## Why this matters beyond Docker

Docker's IPAM refuses outright, which is a loud, obvious failure. Real Ligolo-ng
routing on a live engagement is far less forgiving about telling you what went wrong:
if you `route_add --name pivot1 --route 172.16.10.0/24` on Kali, and you *also* happen
to already have a route for `172.16.10.0/24` from an earlier pivot, a VPN, or a stale
route from a previous lab session, the kernel will pick ONE of them based on its own
routing rules (most specific prefix wins; among equal prefixes, the one with the
better/lowest metric wins) — and you will not get an error. Your scans will simply go
to the wrong place, or nowhere, and you'll waste time debugging Ligolo-ng when the
actual problem is a leftover route.

Always check `ip route show` on Kali BEFORE adding a new Ligolo route, and use
`ip route get <target-ip>` after adding it to confirm which interface and route the
kernel actually chose for that destination — see `course/11-routing/` for the full
method.
