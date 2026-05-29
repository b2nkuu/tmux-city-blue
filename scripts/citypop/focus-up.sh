#!/usr/bin/env bash
# Count-up focus timer: elapsed since current tmux session was created,
# resets to 00:00 at local midnight each day, and respects a manual
# reset written by focus-reset.sh (right-click → reset on the widget).
created=$(tmux display -p '#{session_created}' 2>/dev/null)
[ -z "$created" ] && exit 0

now=$(date +%s)

# Local midnight (start of today) — portable across macOS/Linux.
sec_today=$(( 10#$(date +%H) * 3600 + 10#$(date +%M) * 60 + 10#$(date +%S) ))
midnight=$(( now - sec_today ))

# Manual reset override, scoped to this session.
session_id=$(tmux display -p '#{session_id}' 2>/dev/null | tr -d '$')
reset_file="/tmp/city-blue/focus-reset-${session_id}"
reset_at=0
[ -f "$reset_file" ] && reset_at=$(cat "$reset_file" 2>/dev/null) && reset_at=${reset_at:-0}

# Baseline = latest of (session start, today's midnight, manual reset).
baseline=$created
(( midnight > baseline )) && baseline=$midnight
(( reset_at > baseline )) && baseline=$reset_at

elapsed=$(( now - baseline ))
(( elapsed < 0 )) && elapsed=0

hh=$(( elapsed / 3600 ))
mm=$(( (elapsed % 3600) / 60 ))
printf "%02d:%02d" "$hh" "$mm"
