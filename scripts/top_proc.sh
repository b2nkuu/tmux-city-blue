#!/usr/bin/env bash
# Top CPU-consuming process — name + %CPU.

set -e

read pct cmd < <(ps -arcwwwxo "%cpu command" 2>/dev/null \
  | awk 'NR==2 {p=$1; for(i=2;i<=NF;i++) c=c" "$i; sub(/^ /,"",c); print p" "c}')

[ -z "$pct" ] && exit 0

# Trim command to basename
short=$(basename "$cmd" 2>/dev/null | awk '{print $1}')
[ -z "$short" ] && short="$cmd"

printf "%.10s %s%%" "$short" "$pct"
