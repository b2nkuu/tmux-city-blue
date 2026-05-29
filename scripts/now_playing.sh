#!/usr/bin/env bash
# macOS now-playing — query Music.app or Spotify.app via osascript.
# Output: " Title — Artist" if playing, empty otherwise.

set -e

if ! command -v osascript >/dev/null 2>&1; then
  exit 0
fi

# Spotify first (more common for dev workflows)
spotify_state=$(osascript -e 'tell application "System Events" to (name of processes) contains "Spotify"' 2>/dev/null || echo "false")
if [ "$spotify_state" = "true" ]; then
  state=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null || echo "")
  if [ "$state" = "playing" ]; then
    track=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
    artist=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
    if [ -n "$track" ]; then
      # Truncate to keep statusbar tidy
      out="${track} — ${artist}"
      printf " %.40s" "$out"
      exit 0
    fi
  fi
fi

# Music.app fallback
music_state=$(osascript -e 'tell application "System Events" to (name of processes) contains "Music"' 2>/dev/null || echo "false")
if [ "$music_state" = "true" ]; then
  state=$(osascript -e 'tell application "Music" to player state as string' 2>/dev/null || echo "")
  if [ "$state" = "playing" ]; then
    track=$(osascript -e 'tell application "Music" to name of current track as string' 2>/dev/null)
    artist=$(osascript -e 'tell application "Music" to artist of current track as string' 2>/dev/null)
    if [ -n "$track" ]; then
      out="${track} — ${artist}"
      printf " %.40s" "$out"
      exit 0
    fi
  fi
fi
