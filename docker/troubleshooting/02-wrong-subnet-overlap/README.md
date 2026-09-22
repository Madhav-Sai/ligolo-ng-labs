# Broken Lab 02 — Overlapping Subnets

Run this exactly as it is first:

```bash
docker compose up -d --build
```

Read the actual error Docker gives you. Don't skip to `SOLUTION.md` — the error message
itself is the lesson here (Docker's IPAM manager refuses to create two networks with
overlapping address pools, and this is exactly the class of mistake that also breaks
real Ligolo-ng routing when you reuse a CIDR across two hops that should be distinct,
or when a target network's subnet happens to collide with one you already have a
Ligolo route for from an earlier engagement/lab session).

Fix `docker-compose.yml` yourself (there's a comment marking the bad line), then bring
it up again.

`SOLUTION.md` has the fix and, more importantly, the broader lesson about why
overlapping CIDRs matter for real Ligolo-ng routing even outside Docker.
