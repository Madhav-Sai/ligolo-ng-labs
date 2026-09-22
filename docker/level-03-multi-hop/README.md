# Level 03 — Triple-Hop Docker Lab

Companion lab for `course/09-multi-hop/` Scenario B. Four networks, three pivots, one
critical server at the bottom:

```
kali -> attack_net -> pivot-01 -> internal_net -> pivot-02 -> restricted_net -> pivot-03 -> critical_net -> critical-server
                                       │                            │
                              internal-server-1              internal-server-2
```

Same rules as levels 01/02: every internal network is `internal: true`, only the
pivot straddling two networks can reach both, and `kali` starts with a route to
`attack_net` only. This lab exists specifically to force you to repeat the second-hop
pattern (agent binary handed over the existing tunnel, `listener_add` on the upstream
pivot, new agent registers as a new session) a third time, on a network the previous
pivot can't see either — see the "each hop only sees its own two networks" checks in
`verify.sh`.

```bash
./setup.sh
./verify.sh
./reset.sh
```

## Known limitation

Built and reasoned through, not run end-to-end in this session (see the root
`ligolo-ng-course/README.md` for why). Verify locally before using it.
