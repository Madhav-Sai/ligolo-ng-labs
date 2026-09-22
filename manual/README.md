# Manual VM Lab

The Docker lab in `../docker/` is faster to spin up and tear down, but nothing beats
building the same topology out of real VMs at least once — it forces you to actually
understand VM networking (host-only vs internal vs NAT adapters), which is a skill
you'll need on real engagements where you're not the one who built the network.

This builds the same canonical topology as the Docker lab's level-01/level-02:

```
   KALI                    PIVOT-01                  INTERNAL-SERVER-1
10.10.10.10  <-->  10.10.10.20 / 172.16.10.20  <-->     172.16.10.50
```

Three VMs minimum for the single-hop version. Add a fourth (`pivot-02`, dual-homed
`172.16.10.30` / `192.168.50.30`) and a fifth (`internal-server-2`, `192.168.50.10`) if
you want to also build the double-hop lab from `../../course/08-second-hop/` by hand.

Pick your hypervisor:

- [`linux/README.md`](linux/README.md) — network adapter setup, IP configuration, and
  firewall notes for Linux VMs playing the pivot/internal-server roles (works whether
  your hypervisor is VirtualBox, VMware, or KVM/virt-manager — the guest-OS commands
  are identical, only the adapter configuration screens differ)
- [`windows/README.md`](windows/README.md) — same, for a Windows VM playing pivot-02
  or an internal Windows server/DC role

## General VM networking concepts (both hypervisors)

Every hypervisor gives you roughly three relevant adapter types, and getting them
right is the entire trick to this lab actually being segmented instead of secretly
flat:

- **NAT** — the VM can reach the internet through the host, but other VMs generally
  can't reach IN to it, and it can't be used to build a shared internal segment
  between VMs. Use this ONLY if a VM needs internet access for setup (e.g.
  downloading packages) and isn't part of the segmented topology itself.
- **Host-only network** (VirtualBox) / **custom VMnet** (VMware) / **isolated Linux
  bridge** (KVM) — a private virtual switch that only VMs explicitly attached to it can
  see. This is what `attack_net`, `internal_net`, etc. actually map to. Create ONE of
  these per network in your topology, with a distinct name, and attach only the VMs
  that diagram shows on that segment.
- **Bridged** — puts the VM directly on your physical LAN. Don't use this for the lab
  segments at all — it defeats the entire point of building isolated networks.

A dual-homed VM (pivot-01, pivot-02) simply has TWO virtual network adapters attached
— one to each relevant host-only/VMnet network, exactly like the two `networks:`
entries a Docker service has in this course's compose files.

## Reset procedure

Take a clean snapshot of each VM immediately after its OS is installed and networking
is configured but BEFORE you run any Ligolo-ng lab exercise. Revert to that snapshot
between lab attempts instead of reinstalling — this is the manual-lab equivalent of
the Docker lab's `./reset.sh`.
