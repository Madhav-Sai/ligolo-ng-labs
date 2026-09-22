#!/bin/bash
# Deliberately broken: this rule drops inbound connections to 11601, the port the
# exercise tells you to use for listener_add. Everything else works normally.
iptables -A INPUT -p tcp --dport 11601 -j DROP
exec "$@"
