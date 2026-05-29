#!/usr/bin/env bash
# Network throughput on primary interface — delta vs cached snapshot.
# Output: "↑ 12K ↓ 340K" (auto unit B/K/M)

set -e

cache_dir="${TMPDIR:-/tmp}/tmux-net"
mkdir -p "$cache_dir"

iface=$(route get default 2>/dev/null | awk '/interface:/{print $2}')
iface=${iface:-en0}

cache="$cache_dir/$iface"

read_bytes() {
  netstat -ibn 2>/dev/null \
    | awk -v ifc="$iface" '$1==ifc && $4!="" {ib+=$7; ob+=$10} END{print ib" "ob}'
}

read snap_in snap_out < <(read_bytes)
now=$(date +%s)

if [ -f "$cache" ]; then
  read prev_in prev_out prev_time < "$cache"
  dt=$(( now - prev_time ))
  [ "$dt" -lt 1 ] && dt=1
  rx=$(( (snap_in  - prev_in)  / dt ))
  tx=$(( (snap_out - prev_out) / dt ))
else
  rx=0; tx=0
fi

printf "%s %s %s\n" "$snap_in" "$snap_out" "$now" > "$cache"

human() {
  v=$1
  if   [ "$v" -ge 1048576 ]; then printf "%dM" $(( v / 1048576 ))
  elif [ "$v" -ge 1024    ]; then printf "%dK" $(( v / 1024 ))
  else                            printf "%dB" "$v"
  fi
}

printf "↑ %s ↓ %s" "$(human $tx)" "$(human $rx)"
