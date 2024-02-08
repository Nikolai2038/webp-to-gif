#!/usr/bin/env bash

# Exit on any error
set -e

# Message colors
C_RESET='\e[0m'
C_ERROR='\e[0;31m'
C_COMMAND='\e[0;95m'
C_TEXT_BOLD='\e[1;95m'

main() {
  local dirname="$1" && { shift || true; }
  if [ -z "${dirname}" ]; then
    echo -e "${C_ERROR}Script usage: ${C_COMMAND}./convert_all_in_dir.sh <path to dir> [0|1 - enable transparency] [0|1|2 - compression level]${C_RESET}" >&2
    return 1
  fi
  if [ ! -d "${dirname}" ]; then
    echo -e "${C_ERROR}Directory ${C_TEXT_BOLD}${dirname}${C_ERROR} does not exist!${C_RESET}" >&2
    return 1
  fi

  local folder_with_script
  folder_with_script="$(dirname "$0")"
  local filename_in
  for filename_in in "$dirname"/*; do
    local is_required_extension
    is_required_extension="$(echo -e "$filename_in" | sed -En '/(.*).web[pm]/p')"
    if [ -n "${is_required_extension}" ]; then
      "${folder_with_script}/convert_one.sh" "$filename_in" "$@" || continue
    fi
  done
}

main "$@"
