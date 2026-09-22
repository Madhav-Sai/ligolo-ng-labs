# Ligolo-ng Labs

Hands-on lab environments for the Ligolo-ng Network Pivoting course.

## Quick start

If you have [Docker](https://docs.docker.com/get-docker/) installed, this one command
walks you through starting, verifying, and resetting any of the Docker-based labs —
no need to know which folder to `cd` into or which script to run:

```bash
git clone https://github.com/Madhav-Sai/ligolo-ng-labs.git
cd ligolo-ng-labs
./labs.sh
```

## What's in here

- `docker/` — self-contained Docker Compose lab environments (single-hop, double-hop, multi-hop, enterprise-scale, and troubleshooting scenarios). Each level has its own `setup.sh`, `verify.sh`, and `reset.sh` — `labs.sh` runs these for you.
- `manual/` — manual lab instructions for Linux and Windows targets that don't rely on Docker (`labs.sh` will point you here for these).

Every lab assumes an isolated lab environment or a written, authorized engagement. Nothing here should be run against a network you do not own or have explicit permission to test.

Part of the Ligolo-ng: Advanced Network Pivoting & Tunneling course.
