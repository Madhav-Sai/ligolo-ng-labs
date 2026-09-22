# Level 01 — Single-Hop Docker Lab

This is the lab that goes with `course/05-single-hop/`. Three containers, two Docker
networks, and a real segmentation boundary between them — `internal_net` is declared
`internal: true` in `docker-compose.yml`, which tells Docker's own bridge driver not to
give that network any route out. `kali` is never attached to it. Until you build a
Ligolo-ng tunnel through `pivot-01`, there is no path from `kali` to
`internal-server-1` — not a firewall rule you could disable, an actual missing route.

## Topology

```
   kali (10.10.10.10)
        │
   attack_net — 10.10.10.0/24
        │
   pivot-01 (10.10.10.20 / 172.16.10.20)
        │
   internal_net — 172.16.10.0/24  (internal: true, no route out)
        │
   internal-server-1 (172.16.10.50)  — serves a tiny site on :80
```

| Container | Image base | Role | IPs |
|---|---|---|---|
| kali | debian:bookworm-slim + ligolo-ng proxy | attacker | 10.10.10.10 |
| pivot-01 | debian:bookworm-slim + ligolo-ng agent | compromised DMZ host | 10.10.10.20, 172.16.10.20 |
| internal-server-1 | python:3.12-slim | internal-only target | 172.16.10.50 |

The `kali` container uses a minimal Debian image, not the real `kalilinux/kali-rolling`
image, to keep builds fast and reproducible without a multi-GB pull. The `proxy`
binary and the tools this lab actually uses (curl, nmap, netcat, iproute2) behave
identically to running them on real Kali. Swap the `FROM` line in `kali/Dockerfile` if
you want the real image.

## Requirements

- Docker Engine with Compose v2 (`docker compose`, not the old standalone
  `docker-compose`).
- Your user needs to actually run docker commands (`docker ps` should work without
  `sudo`; if it doesn't, add yourself to the `docker` group and log back in, or run
  every command in this lab with `sudo`).
- Internet access at build time — the Dockerfiles download the real
  `ligolo-ng_proxy_0.9.1_linux_amd64.tar.gz` / `ligolo-ng_agent_0.9.1_linux_amd64.tar.gz`
  release assets from GitHub. If you're on a different CPU architecture, override the
  build arg: `docker compose build --build-arg TARGETARCH=arm64`.

## Run it

```bash
./setup.sh     # builds the three images and starts the lab
./verify.sh    # confirms segmentation is real BEFORE you build any tunnel
```

`verify.sh` is meant to be run twice: once right after `setup.sh` (it should report
kali **cannot** reach `172.16.10.50`), and again after you've completed the pivot lab
(at that point, reachability through the tunnel is a separate manual check — `ping`
from inside the netns doesn't reflect a userland TUN route the same way host tools do,
see the note in `course/05-single-hop/` about verifying from the actual Kali shell).

## Get a shell

```bash
docker compose exec kali bash
docker compose exec pivot-01 bash
docker compose exec internal-server-1 bash
```

Do the pivot lab from here — full walkthrough in `../../../course/05-single-hop/`.

## Reset

```bash
./reset.sh            # stop and remove containers + networks
./reset.sh --images    # also remove the built images, for a fully clean rebuild
```

## Known limitation (be upfront about this)

This lab was authored and reviewed for correctness (valid Compose v2 YAML, verified
against `docker compose config`, IPs and network isolation reasoned through carefully),
but it was **not** run end-to-end in the environment this course was written in — the
build user didn't have working Docker daemon access there. Run `./setup.sh` followed by
`./verify.sh` yourself before your first session; if `verify.sh` reports any FAIL lines,
check `../../troubleshooting/` and open an issue-style note in
`../troubleshooting/` describing what you saw.
