#!/usr/bin/env bash
# GitHub unread notifications count via gh CLI. Cached 60s to avoid API spam.

if ! command -v gh >/dev/null 2>&1; then exit 0; fi

cache="${TMPDIR:-/tmp}/tmux-gh-notif.cache"
ttl=60

if [ -f "$cache" ]; then
  age=$(( $(date +%s) - $(stat -f %m "$cache" 2>/dev/null || stat -c %Y "$cache") ))
  if [ "$age" -lt "$ttl" ]; then
    cat "$cache"
    exit 0
  fi
fi

count=$(gh api notifications --jq 'length' 2>/dev/null)
[ -z "$count" ] && count=0
printf "%s" "$count" > "$cache"
printf "%s" "$count"
