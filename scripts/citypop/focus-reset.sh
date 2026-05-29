#!/usr/bin/env bash
# Mark "now" as the focus timer baseline for the current session so the
# count-up display restarts from 00:00. focus-up.sh reads this file.
session_id=$(tmux display -p '#{session_id}' 2>/dev/null | tr -d '$')
[ -z "$session_id" ] && exit 1
mkdir -p /tmp/city-blue
date +%s > "/tmp/city-blue/focus-reset-${session_id}"
tmux refresh-client -S 2>/dev/null || true
