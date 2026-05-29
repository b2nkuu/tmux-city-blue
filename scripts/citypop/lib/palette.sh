#!/usr/bin/env bash
# city-blue palette — extracted from upstream citypop-tn src/themes.sh (citypop case only).
# Source from any widget script: source "$(dirname "$0")/lib/palette.sh"

TRANSPARENT_THEME="$(tmux show-option -gv @city-blue_transparent 2>/dev/null)"

declare -A THEME=(
  ["background"]="#0a1929"
  ["foreground"]="#cdd9e5"
  ["black"]="#102a43"
  ["blue"]="#4cc9f0"
  ["cyan"]="#56cfe1"
  ["green"]="#64dfdf"
  ["magenta"]="#9d4edd"
  ["red"]="#ff6b6b"
  ["white"]="#e0fbfc"
  ["yellow"]="#ffd166"

  ["bblack"]="#1e4d7a"
  ["bblue"]="#48cae4"
  ["bcyan"]="#80ffdb"
  ["bgreen"]="#80ed99"
  ["bmagenta"]="#b8c0ff"
  ["bred"]="#ff8fa3"
  ["bwhite"]="#a8dadc"
  ["byellow"]="#ffba08"
)

if [ "${TRANSPARENT_THEME}" == 1 ]; then
  THEME["background"]="default"
fi

THEME['ghgreen']="#3fb950"
THEME['ghmagenta']="#A371F7"
THEME['ghred']="#d73a4a"
THEME['ghyellow']="#d29922"

RESET="#[fg=${THEME[foreground]},bg=${THEME[background]},nobold,noitalics,nounderscore,nodim]"
