#!/usr/bin/env bash
# macOS thermal pressure level. Output: "OK" / "WARN" / "HOT" / "CRIT".

if ! command -v pmset >/dev/null 2>&1; then exit 0; fi

state=$(pmset -g therm 2>/dev/null | awk -F': ' '/CPU_Speed_Limit/{print $2}' | tr -d ' ')

if [ -z "$state" ] || [ "$state" = "100" ]; then
  printf "OK"
elif [ "$state" -ge 80 ]; then
  printf "WARN"
elif [ "$state" -ge 50 ]; then
  printf "HOT"
else
  printf "CRIT"
fi
