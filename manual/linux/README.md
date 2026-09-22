# Manual Lab — Linux VMs

Builds `pivot-01` (and optionally `pivot-02`, `internal-server-1`, `internal-server-2`)
as real Linux VMs. Any distro works for the pivot roles — Debian/Ubuntu minimal
installs are the lightest. Use whatever you're already comfortable installing quickly;
none of this depends on a specific distro.

## VM list for the single-hop lab

| VM | Role | Adapters |
|---|---|---|
| kali | attacker | 1 (attached to `attack_net`) |
| pivot-01 | pivot | 2 (`attack_net` + `internal_net`) |
| internal-server-1 | target | 1 (`internal_net`) |

Add `pivot-02` (2 adapters: `internal_net` + `restricted_net`) and
`internal-server-2` (1 adapter: `restricted_net`) for the double-hop lab from
`../../../course/08-second-hop/`.

## 1. Create the virtual networks first

**VirtualBox** (Host > Tools > Network Manager, or CLI):
```bash
VBoxManage hostonlyif create                      # creates vboxnet0 (repeat for more)
VBoxManage hostonlyif ipconfig vboxnet0 --ip 10.10.10.1 --netmask 255.255.255.0
VBoxManage hostonlyif create                      # vboxnet1 for internal_net
VBoxManage hostonlyif ipconfig vboxnet1 --ip 172.16.10.1 --netmask 255.255.255.0
```
Note: VirtualBox's host-only network reserves `.1` for the host itself — that's fine,
none of this lab's guest IPs use `.1`.

**VMware Workstation**: open Edit > Virtual Network Editor > Add Network, create a
custom VMnet per segment (e.g. `VMnet2` for attack_net, `VMnet3` for internal_net),
untick "Connect a host virtual adapter" and "Use local DHCP service" unless you
specifically want DHCP (this lab uses static IPs to match the course exactly).

**KVM/virt-manager**: create an isolated bridge per network (Edit > Connection Details
> Virtual Networks > +), mode "Isolated network: Internal to this host", no DHCP if
you want to set static IPs matching the canonical scheme.

## 2. Attach adapters per VM

In each VM's settings (not inside the guest OS): set the correct adapter count and
point each one at the matching host-only network / VMnet / isolated bridge from step
1. `pivot-01` gets one adapter on the attack-facing network and a second adapter on
the internal-facing network — this is the manual-lab equivalent of the two `networks:`
entries in the Docker Compose files.

## 3. Configure static IPs inside each guest

Check your interface names first — they won't necessarily be `eth0`/`eth1` (Debian
12+ uses predictable names like `enp0s3`):

```bash
[ANY LINUX VM] ip -brief addr
```

Using Netplan (Ubuntu) — edit `/etc/netplan/01-lab.yaml`:
```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses: [10.10.10.20/24]
    enp0s8:
      addresses: [172.16.10.20/24]
```
```bash
[PIVOT-01] sudo netplan apply
```

Or with plain `ifupdown` (`/etc/network/interfaces`):
```
auto enp0s3
iface enp0s3 inet static
    address 10.10.10.20
    netmask 255.255.255.0

auto enp0s8
iface enp0s8 inet static
    address 172.16.10.20
    netmask 255.255.255.0
```

Repeat with the appropriate single IP for `internal-server-1`
(`172.16.10.50`, one adapter only) and `kali` (`10.10.10.10`, one adapter only, plus
whatever NAT/bridged adapter you use separately for internet access to download tools
— don't let that adapter share a network with anything in the lab topology).

## 4. No gateway needed between segments

Notice there's deliberately no default gateway configured pointing between
`attack_net` and `internal_net` — you're not trying to make these networks route to
each other at the OS level. That's the entire point: reachability across them should
happen ONLY through the Ligolo-ng tunnel you build in `../../../course/05-single-hop/`,
not through IP forwarding or a router VM. If you find yourself wanting to add IP
forwarding to make the lab "easier," you're accidentally defeating the exercise.

## 5. Firewall considerations

Most minimal Linux installs have no host firewall active by default — verify with
`sudo iptables -L -n` or `sudo nft list ruleset`. If your distro's install DOES enable
one (some hardened cloud images do), you may need an explicit ACCEPT rule for whatever
port you choose for the Ligolo-ng listener in later labs — see
`../../../troubleshooting/07-platform-and-environment.md`.

## 6. Test connectivity before touching Ligolo-ng

```bash
[KALI]     ping -c1 10.10.10.20          # kali -> pivot-01, should work
[KALI]     ping -c1 172.16.10.50         # kali -> internal-server-1, should FAIL
[PIVOT-01] ping -c1 172.16.10.50         # pivot-01 -> internal-server-1, should work
```
If the second line succeeds, your networks aren't actually segmented and the lab won't
teach you anything — go back to step 1/2 and check adapter assignments.

## 7. Snapshot, then proceed

Once step 6 confirms correct segmentation, take a clean snapshot of every VM. Then
follow `../../../course/05-single-hop/` exactly as written — every command and IP in
that module matches this topology.

## Reset

Revert each VM to its post-step-6 snapshot rather than reconfiguring networking by
hand every time.
