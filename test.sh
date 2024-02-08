#!/usr/bin/env bash

# Exit on any error
set -e

main() {
  local directory_with_this_script
  directory_with_this_script="$(dirname "${BASH_SOURCE[0]}")"

  # Clear old files
  rm "${directory_with_this_script}/data/examples"/*.gif 2> /dev/null || true

  # Generate new files
  "${directory_with_this_script}/convert_all_in_dir.sh" "${directory_with_this_script}/data/examples"
}

main "$@"
