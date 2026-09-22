# Broken Lab 01 — The Listener That Never Answers

**Symptom you'll see:** you complete the single-hop pivot through `pivot-01` fine.
You run `listener_add --addr 0.0.0.0:11601 --to 127.0.0.1:11601` against the pivot-01
session, copy the agent binary to `pivot-02` (172.16.10.30), and run:

```
[PIVOT-02] ./agent -connect 172.16.10.20:11601 -ignore-cert
```

...and it just hangs. No error, no connection, nothing in the proxy console either.

## Setup

```bash
docker compose up -d --build
docker compose exec kali bash
```

Do the normal single-hop pivot from `course/05-single-hop/` first (kali -> pivot-01 ->
internal-server-1), confirm it works, THEN try to chain pivot-02 through pivot-01 as
described above and watch it fail.

## Your job

Diagnose it like a real broken pivot, using the method from `course/11-routing/` and
`course/13-troubleshooting/` — don't just read the solution file. Start with the two
separate questions that module drills into you: "can pivot-02 reach pivot-01 at all?"
vs "is something on pivot-01 actually listening and accepting on port 11601?" Useful
commands from inside `pivot-02`'s shell (`docker compose exec pivot-02 bash`): `ping
172.16.10.20`, `nc -zv 172.16.10.20 11601`. Useful commands from inside `pivot-01`'s
shell: `ss -tlnp`, and — the one that actually reveals this specific fault —
`iptables -L -n`.

Solution: `SOLUTION.md` (don't open it until you've at least run `iptables -L -n` on
pivot-01 yourself).

Reset: `docker compose down -v`.
