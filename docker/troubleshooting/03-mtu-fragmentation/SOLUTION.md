# Solution — Broken Lab 03

`internal_net`'s bridge MTU is 576. `attack_net` (and the ligolo TUN interface on Kali,
which defaults to 1500) is not. A large HTTP response crossing that boundary gets
fragmented, and if anything in the path also has the "don't fragment" behavior in play
(or the fragments just get mishandled by the userland gVisor stack reassembling
oddly-sized packets relayed through the tunnel), the transfer stalls instead of
cleanly failing.

## Confirm it

```
[PIVOT-01] ip link show eth1
```
shows `mtu 576` on the internal_net-facing interface, versus 1500 on `eth0`
(attack_net-facing).

```
[PIVOT-01] ping -M do -s 1400 172.16.10.50
```
fails with "Frag needed and DF set" once you cross the effective MTU ceiling, while
```
[PIVOT-01] ping -M do -s 500 172.16.10.50
```
succeeds. That size threshold is your proof.

## Fix

In a Docker lab, the fix is simply correcting the `driver_opts` MTU back to something
sane (or removing it, to use the default). On a **real** engagement you can't edit the
target network's MTU — what you actually do is:

1. Confirm the working MTU ceiling with the `ping -M do -s <size>` sweep above.
2. Lower the Ligolo-ng TUN interface's MTU on Kali to match (Ligolo-ng doesn't expose
   an interactive MTU flag on the interface commands as of v0.9.1 — if you hit this on
   a real engagement, the practical workaround is setting the TUN interface's MTU
   directly at the OS level once `interface_create` has made it, e.g.
   `sudo ip link set dev <tunname> mtu 576` on Kali) so packets never get built larger
   than the smallest link in the path can carry unfragmented.
3. Re-test with the same large-file request.

## Verify

```
[KALI - SHELL] curl http://172.16.10.50/large-file.bin -o /dev/null -w '%{size_download}\n'
```
should now complete and report the full 500000 bytes instead of stalling.
