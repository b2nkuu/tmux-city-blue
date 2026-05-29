#!/usr/bin/env bash

# Check if enabled
ENABLED=$(tmux show-option -gv @city-blue_show_git)
[[ ${ENABLED} -ne 1 ]] && exit 0

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${ROOT_DIR}/lib/coreutils-compat.sh"
source "${ROOT_DIR}/lib/palette.sh"

cd "$1" || exit 1
RESET="#[fg=${THEME[foreground]},bg=${THEME[bblack]},nobold,noitalics,nounderscore,nodim]"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
STATUS=$(git status --porcelain 2>/dev/null | grep -cE "^(M| M)")

SYNC_MODE=0
NEED_PUSH=0

if [[ ${#BRANCH} -gt 25 ]]; then
  BRANCH="${BRANCH:0:25}…"
fi

STATUS_CHANGED=""
STATUS_INSERTIONS=""
STATUS_DELETIONS=""
STATUS_UNTRACKED=""

if [[ $STATUS -ne 0 ]]; then
  DIFF_COUNTS=($(git diff --numstat 2>/dev/null | awk 'NF==3 {changed+=1; ins+=$1; del+=$2} END {printf("%d %d %d", changed, ins, del)}'))
  CHANGED_COUNT=${DIFF_COUNTS[0]}
  INSERTIONS_COUNT=${DIFF_COUNTS[1]}
  DELETIONS_COUNT=${DIFF_COUNTS[2]}

  SYNC_MODE=1
fi

UNTRACKED_COUNT="$(git ls-files --other --exclude-standard | wc -l | bc)"

WHITE="${THEME[white]:-#ffffff}"
DARK_YELLOW="#b8860b"
DARK_GREEN="#1b7d5a"
DARK_RED="#a02828"
DARK_BLACK="#0a1929"

if [[ $CHANGED_COUNT -gt 0 ]]; then
  STATUS_CHANGED="${RESET}#[fg=${WHITE},bg=${DARK_YELLOW},bold]  ${CHANGED_COUNT} "
fi

if [[ $INSERTIONS_COUNT -gt 0 ]]; then
  STATUS_INSERTIONS="${RESET}#[fg=${WHITE},bg=${DARK_GREEN},bold]  ${INSERTIONS_COUNT} "
fi

if [[ $DELETIONS_COUNT -gt 0 ]]; then
  STATUS_DELETIONS="${RESET}#[fg=${WHITE},bg=${DARK_RED},bold]  ${DELETIONS_COUNT} "
fi

if [[ $UNTRACKED_COUNT -gt 0 ]]; then
  STATUS_UNTRACKED="${RESET}#[fg=${WHITE},bg=${DARK_BLACK},bold]  ${UNTRACKED_COUNT} "
fi

# Determine repository sync status
if [[ $SYNC_MODE -eq 0 ]]; then
  NEED_PUSH=$(git log @{push}.. | wc -l | bc)
  if [[ $NEED_PUSH -gt 0 ]]; then
    SYNC_MODE=2
  else
    LAST_FETCH=$(stat -c %Y .git/FETCH_HEAD | bc)
    NOW=$(date +%s | bc)

    # if 5 minutes have passed since the last fetch
    if [[ $((NOW - LAST_FETCH)) -gt 300 ]]; then
      git fetch --atomic origin --negotiation-tip=HEAD
    fi

    # Check if the remote branch is ahead of the local branch
    REMOTE_DIFF="$(git diff --numstat "${BRANCH}" "origin/${BRANCH}" 2>/dev/null)"
    if [[ -n $REMOTE_DIFF ]]; then
      SYNC_MODE=3
    fi
  fi
fi

# Set the status indicator based on the sync mode
case "$SYNC_MODE" in
1)
  SYNC_COLOR="${THEME[bred]}"; SYNC_ICON="󱓎"
  ;;
2)
  SYNC_COLOR="${THEME[red]}"; SYNC_ICON="󰛃"
  ;;
3)
  SYNC_COLOR="${THEME[magenta]}"; SYNC_ICON="󰛀"
  ;;
*)
  SYNC_COLOR="${THEME[green]}"; SYNC_ICON=""
  ;;
esac

if [[ -n $BRANCH ]]; then
  ICON_SEG="#[fg=${THEME[background]},bg=${SYNC_COLOR},bold] ${SYNC_ICON} "
  BRANCH_SEG="#[fg=${THEME[foreground]},bg=${THEME[bblack]},nobold] $BRANCH "
  echo "$ICON_SEG$BRANCH_SEG$STATUS_CHANGED$STATUS_INSERTIONS$STATUS_DELETIONS$STATUS_UNTRACKED"
fi
