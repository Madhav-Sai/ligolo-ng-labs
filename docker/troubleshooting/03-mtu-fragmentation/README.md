# Broken Lab 03 — MTU / Fragmentation

Bring the lab up and do the normal single-hop pivot from `course/05-single-hop/`.

```bash
docker compose up -d --build
```

`internal_net` here is capped at a 576-byte MTU instead of the usual 1500 (see the
`driver_opts` in `docker-compose.yml` — this is a real Docker Compose feature, not a
Ligolo-ng one; it's standing in for a low-MTU link you'd hit for real behind a VPN, a
GRE tunnel, or certain cloud/WAN setups).

## Symptom

Small requests through your tunnel work fine:

```
[KALI - SHELL] curl http://172.16.10.50/
```

...but this one stalls or times out:

```
[KALI - SHELL] curl http://172.16.10.50/large-file.bin
```

This is the classic MTU-problem fingerprint from `course/13-troubleshooting/` and
`../../../troubleshooting/`: **small stuff works, big stuff hangs.** ICMP ping (small
packets) will look completely healthy the whole time, which is exactly why people
waste time re-checking routes when the actual problem is packet size.

## Your job

Work through it using the diagnostic steps in the troubleshooting reference
(`../../../troubleshooting/07-mtu-and-fragmentation.md` if you've generated it, or the
MTU section of `course/13-troubleshooting/`) before opening `SOLUTION.md`. Useful
commands: `ip link show` on both kali and pivot-01 to compare MTU per interface, and a
`ping -M do -s <size>` sweep from pivot-01 toward internal-server-1 to find where
fragmentation-needed-but-DF-set packets start getting silently dropped.

Reset: `docker compose down -v`.
