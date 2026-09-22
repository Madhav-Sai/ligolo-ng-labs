# Level 02 — Double-Hop Docker Lab

Companion lab for `course/08-second-hop/`. Extends level-01 with a second segmented
network and a second pivot.

```
kali (10.10.10.10)
   │  attack_net 10.10.10.0/24
pivot-01 (10.10.10.20 / 172.16.10.20)
   │  internal_net 172.16.10.0/24 (internal: true)
   ├── internal-server-1 (172.16.10.50)
   └── pivot-02 (172.16.10.30 / 192.168.50.30)
          │  restricted_net 192.168.50.0/24 (internal: true)
       internal-server-2 (192.168.50.10)
```

Three separate Docker networks, two of them `internal: true`. `pivot-02` is the only
container that straddles `internal_net` and `restricted_net`, exactly the way a real
second pivot host would be the only machine with a leg into both segments. There is no
route from `kali` into `restricted_net` at all — not even indirectly — until you've
built both hops of the tunnel.

## Run it

```bash
./setup.sh
./verify.sh
```

`verify.sh` checks all five containers, confirms `kali` can reach neither
`internal_net` nor `restricted_net` directly, confirms `pivot-01` cannot reach
`restricted_net` (only `pivot-02` can — this is the detail people get wrong when they
first reason about double pivots), and confirms the agent/proxy binaries are present.

## The lab itself

Full walkthrough in `../../../course/08-second-hop/`. In short: `pivot-01`'s agent
opens a `listener_add` relay so `pivot-02`'s agent (copied over via the already-tunneled
`internal_net`) can register with the same proxy running on `kali`, without ever
needing a direct route back to `10.10.10.10`.

## Reset

```bash
./reset.sh
./reset.sh --images
```

## Known limitation

Same as level-01: built and reasoned through carefully (valid Compose v2 YAML,
verified network topology, no accidental routes), but not run end-to-end in this
session due to Docker daemon permissions in the build environment. Run `./verify.sh`
yourself before starting the lab.
