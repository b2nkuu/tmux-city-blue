#!/usr/bin/env bash
# Docker running container count. Empty if daemon down.

if ! command -v docker >/dev/null 2>&1; then exit 0; fi
count=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
[ -z "$count" ] && exit 0
[ "$count" = "0" ] && exit 0
printf "%s" "$count"
