#!/usr/bin/env bash
# Disk usage % of /, plus free space.

set -e

read pct free < <(df -h / | awk 'NR==2 {gsub(/%/,"",$5); print $5" "$4}')
printf "%s%% (%s free)" "$pct" "$free"
