#!/usr/bin/env bash

# Exit on any error
set -e

main() {
  # Getting the name of the input file
  local filename_in="$1" && { shift || true; }
  if [ -z "${filename_in}" ]; then
    echo -e "${C_ERROR}Script usage: ${C_COMMAND}./script.sh <file_path> [0|1 - enable transparency] [0|1|2 - compression level]${C_RESET}" >&2
    return 1
  fi

  local is_transparent=${1:-1} && { shift || true; }
  local compression_level=${1:-1} && { shift || true; }

  docker-compose exec webp-to-gif-service bash -c "
    /app/clear.sh &> /dev/null;
    /app/convert_one.sh \"${filename_in}\" \"${is_transparent}\" \"${compression_level}\"
  "

#  docker-compose exec webp-to-gif-service bash -c '
#    /app/clear.sh;
#    /app/convert_all_in_dir.sh /app/data/examples
#  '
}

main "$@"
