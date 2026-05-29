#!/usr/bin/env bash
# macOS RAM usage percentage — used pages / total pages.

set -e

pagesize=$(sysctl -n hw.pagesize)
total_bytes=$(sysctl -n hw.memsize)

# vm_stat returns counts of pages
vm=$(vm_stat)
pages_active=$(echo "$vm"     | awk '/Pages active/                {gsub(/\./,"",$3); print $3}')
pages_wired=$(echo "$vm"      | awk '/Pages wired down/            {gsub(/\./,"",$4); print $4}')
pages_compressed=$(echo "$vm" | awk '/Pages occupied by compressor/{gsub(/\./,"",$5); print $5}')

used_bytes=$(( (pages_active + pages_wired + pages_compressed) * pagesize ))
pct=$(( used_bytes * 100 / total_bytes ))

printf "%s%%" "$pct"
