#!/usr/bin/env bash
# Local IP of primary interface.

set -e

iface=$(route get default 2>/dev/null | awk '/interface:/{print $2}')
iface=${iface:-en0}
ip=$(ipconfig getifaddr "$iface" 2>/dev/null)
[ -z "$ip" ] && ip="—"
printf "%s" "$ip"
