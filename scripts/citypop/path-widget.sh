#!/usr/bin/env bash

# check if enabled
ENABLED=$(tmux show-option -gv @city-blue_show_path 2>/dev/null)
[[ ${ENABLED} -ne 1 ]] && exit 0

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${ROOT_DIR}/lib/coreutils-compat.sh"
source "${ROOT_DIR}/lib/palette.sh"

PATH_FORMAT=$(tmux show-option -gv @city-blue_path_format 2>/dev/null) # full | relative

current_path="${1}"
default_path_format="relative"
PATH_FORMAT="${PATH_FORMAT:-$default_path_format}"

if [[ ${PATH_FORMAT} == "relative" ]]; then
  current_path="$(echo "${current_path}" | sed 's#'"$HOME"'#~#g')"
fi

echo "#[default] ${current_path} "
