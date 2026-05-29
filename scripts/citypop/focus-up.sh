#!/usr/bin/env bash
# Count-up focus timer: elapsed since current tmux session was created,
# but resets to 00:00 at local midnight each day.
created=$(tmux display -p '#{session_created}' 2>/dev/null)
[ -z "$created" ] && exit 0

now=$(date +%s)

# Local midnight (start of today) — portable across macOS/Linux.
sec_today=$(( 10#$(date +%H) * 3600 + 10#$(date +%M) * 60 + 10#$(date +%S) ))
midnight=$(( now - sec_today ))

# Baseline = later of (session start, today's midnight).
baseline=$created
(( midnight > baseline )) && baseline=$midnight

elapsed=$(( now - baseline ))
(( elapsed < 0 )) && elapsed=0

hh=$(( elapsed / 3600 ))
mm=$(( (elapsed % 3600) / 60 ))
printf "%02d:%02d" "$hh" "$mm"
