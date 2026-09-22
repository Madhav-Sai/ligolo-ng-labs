# Level 04 — Enterprise-Style Docker Lab

Companion lab for `course/16-capstone/`. Four networks, three pivots, and two side
branches (a database host hanging off the internal network, a management host hanging
off the restricted network) so the topology isn't purely linear — you have to actually
enumerate each pivot's networks to find the branch, not just follow one cable forward.

```
kali --dmz_net--> pivot-dmz --internal_net--> pivot-internal --restricted_net--> pivot-restricted --deep_net--> final-target
                        │                            │
                    db-server                   mgmt-server
```

`mgmt-server` stands in for a Windows management host in the course capstone's
narrative (real Windows-specific commands for that box are covered in
`course/16-capstone/` and `course/06-windows-pivot/`) — this lab runs it as a Linux
container so the whole thing works on a plain Linux Docker host without needing
Windows containers. The segmentation behavior (what's reachable from where) is
identical either way; only the OS-specific enumeration commands would differ on the
real thing.

```bash
./setup.sh
./verify.sh
./reset.sh
```

## Known limitation

Built and reasoned through carefully, not run end-to-end in this session — see the
root `ligolo-ng-course/README.md`. This is the largest lab in the course (7
containers, 4 networks); verify it locally before relying on it for the capstone.
