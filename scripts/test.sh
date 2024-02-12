#!/bin/bash

# Exit on any error
set -e

main() {
  local directory_with_this_script
  directory_with_this_script="$(dirname "${BASH_SOURCE[0]}")"

  # Generate new files
  "${directory_with_this_script}/convert_all_in_dir.sh" "${directory_with_this_script}/../data/examples"
}

main "$@"
