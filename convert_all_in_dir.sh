#!/usr/bin/env bash

# Message colors
C_RESET='\e[0m'
C_ERROR='\e[0;31m'
C_COMMAND='\e[0;95m'

dirname="$1" && shift
if [[ -z "${dirname}" ]]; then
    echo -e "${C_ERROR}Script usage: ${C_COMMAND}./convert_all_in_dir.sh <path to dir> [0|1 - enable transparency] [0|1|2 - compression level]${C_RESET}" >&2
    exit 1
fi

folder_with_script=$(dirname "$0")
for filename_in in "$dirname"/*; do
    is_required_extension=$(echo -e "$filename_in" | sed -En '/(.*).web[pm]/p')
    if [[ -n "${is_required_extension}" ]]; then
        "${folder_with_script}/convert_one.sh" "$filename_in" "$@" || continue
    fi
done
