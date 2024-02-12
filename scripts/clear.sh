#!/bin/bash

# Exit on any error
set -e

main() {
  local directory_with_this_script
  directory_with_this_script="$(dirname "${BASH_SOURCE[0]}")"

  # Clear generated files
  if [ "$(find "${directory_with_this_script}/../data/examples" -name '*.gif' | wc -l)" -gt 0 ]; then
    rm "${directory_with_this_script}/../data/examples"/*.gif
  fi
}

main "$@"
