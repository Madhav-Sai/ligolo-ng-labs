# Troubleshooting Labs

Three small, independent, deliberately-broken labs. Each is its own `docker-compose.yml`
in its own folder — they don't share containers with the main level-01..04 labs, so you
can leave one running without it interfering with anything else.

| Lab | Fault category (from `../../../troubleshooting/`) | What breaks |
|---|---|---|
| `01-blocked-listener/` | Listener/connection problems, host firewall | A second agent can't register through pivot-01's listener |
| `02-wrong-subnet-overlap/` | Overlapping subnet, duplicate IP | The lab won't even start — Docker itself refuses the network config |
| `03-mtu-fragmentation/` | MTU/fragmentation, "ping works but big transfers don't" | Large HTTP responses stall through the tunnel |

Each folder has its own `README.md` with the exercise and its own `SOLUTION.md` kept
separate so you're not spoiled scrolling past it by accident. Do the diagnosis
yourself first — use `../../../troubleshooting/` (the full symptom → cause → check →
fix → verify reference) and `course/11-routing/`, `course/13-troubleshooting/` as your
method, not as a lookup table for these three specific answers.

```bash
cd 01-blocked-listener && docker compose up -d --build
# ...work the lab...
docker compose down -v
cd ../02-wrong-subnet-overlap && docker compose up -d --build
# ...
```

## Known limitation

These three labs are built to be self-explanatory about their own fault (the compose
files are heavily commented), but — like the rest of `labs/docker/` — they were not run
end-to-end in the session that authored this course, due to no working Docker daemon
access in that environment. Verify each one locally before relying on it.
