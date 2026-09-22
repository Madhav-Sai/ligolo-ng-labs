# Solution — Broken Lab 01

`pivot-01`'s container entrypoint installs `iptables -A INPUT -p tcp --dport 11601 -j
DROP` at startup (see `pivot-01/entrypoint.sh`). The Ligolo-ng agent's own outbound
connection to Kali is unaffected — DROP on INPUT only blocks things trying to connect
*into* pivot-01, which is exactly what pivot-02's registration attempt is doing when it
dials `172.16.10.20:11601`.

## How you'd find this on a real engagement

1. `nc -zv 172.16.10.20 11601` from pivot-02's shell — this hangs/times out instead of
   printing "succeeded", which tells you the problem is on the network path or the
   target's own host firewall, not in Ligolo-ng's console at all.
2. From pivot-01's shell: `ss -tlnp` — this DOES show something listening on
   `0.0.0.0:11601` (the `listener_add` relay is running fine), which rules out "nothing
   is listening" and narrows it to "something is blocking the connection before it
   reaches that listener."
3. `iptables -L -n` on pivot-01 shows the DROP rule on INPUT for dport 11601.

## Fix

On a real engagement you'd either get the rule removed (if you have the access and
authorization to modify host firewall state — often you don't, or won't want to touch
production hardening) or, more commonly, just pick a **different port** for the
listener that isn't blocked:

```
[KALI - PROXY CONSOLE] listener_add --addr 0.0.0.0:44553 --to 127.0.0.1:11601
[PIVOT-02] ./agent -connect 172.16.10.20:44553 -ignore-cert
```

## Verify

```
[KALI - PROXY CONSOLE] tunnel_list
```
should now show pivot-02 as a second, online session.
