# Manual Lab — Windows VM

Builds a Windows VM playing `pivot-02` (dual-homed, `172.16.10.30` / `192.168.50.30`)
for the mixed-OS chain in `../../../course/09-multi-hop/` Scenario C, or as a Windows
target for `../../../course/06-windows-pivot/`. Any licensed Windows 10/11 or Windows
Server evaluation ISO works — this course doesn't depend on a specific edition.

## VM settings

Attach two virtual network adapters, same as the Linux pivot: one on `internal_net`
(the network `pivot-01` bridges into), one on `restricted_net` (the deeper network this
Windows box bridges into). Follow `../linux/README.md` steps 1-2 for creating the
underlying host-only networks/VMnets/isolated bridges first — that part is
hypervisor-level and identical regardless of guest OS.

## Configure static IPs

**GUI**: Settings > Network & Internet > Change adapter options > right-click each
adapter > Properties > Internet Protocol Version 4 > Use the following IP address.

**PowerShell** (faster, and what you'll actually use on a real engagement where you
don't get a GUI):
```
PS C:\> Get-NetAdapter | ft Name,InterfaceDescription,Status
# identify which adapter is which by checking Status/LinkSpeed against which vNIC you
# attached to which network in the VM settings

PS C:\> New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 172.16.10.30 -PrefixLength 24
PS C:\> New-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress 192.168.50.30 -PrefixLength 24
```

Do NOT set a default gateway on either adapter unless a specific lesson tells you to —
same reasoning as the Linux lab: reachability across segments should come from the
Ligolo-ng tunnel, not from IP routing/forwarding configured on the VM itself.

## Windows Firewall

Leave the default profile settings alone for the base lab (outbound allowed, inbound
blocked) — this is realistic and is exactly the behavior
`../../../course/06-windows-pivot/03-windows-firewall-and-listeners.md` is built to
teach you to work with. You'll only need to open a specific inbound rule if a lesson
has you add a `listener_add` targeting this Windows box (chaining a further agent
through it) — see that lesson for the exact `New-NetFirewallRule` command and why it's
needed.

```
PS C:\> Get-NetFirewallProfile | Select Name,Enabled
```
should show all three profiles (Domain/Private/Public) `Enabled: True` by default —
that's the expected, realistic starting state.

## Test connectivity before touching Ligolo-ng

```
PS C:\> Test-NetConnection -ComputerName 172.16.10.20          # this Windows box -> pivot-01
PS C:\> Test-NetConnection -ComputerName 192.168.50.10          # this Windows box -> internal-server-2/DC
```
Both should succeed (you're on the same subnet as each in this topology). Then from
Kali:
```
[KALI] ping -c1 192.168.50.10
```
should FAIL — Kali has no route to `restricted_net` until the pivot chain through this
Windows box is actually built.

## Getting the agent onto this VM

Copy `agent.exe` over however fits your lab setup (a shared folder if your hypervisor
supports one, `Invoke-WebRequest` from a temporary lab web server, or literally
dragging the file in through the hypervisor's GUI file-transfer feature). On a real
engagement this step is "however you already have file transfer capability on this
foothold" — Ligolo-ng doesn't care how the binary arrives, only that it runs.

```
PS C:\> .\agent.exe -connect 172.16.10.20:11601 -ignore-cert
```
(the pivot-01 listener address, not Kali's — see
`../../../course/08-second-hop/` for why).

## Snapshot, then proceed

Once connectivity checks above pass, snapshot the VM. Follow
`../../../course/09-multi-hop/03-scenario-c-mixed-os-chain.md` for the full walkthrough.

## Reset

Revert to the post-verification snapshot rather than reconfiguring by hand each time.
