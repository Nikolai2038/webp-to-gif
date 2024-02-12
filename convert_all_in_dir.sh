#!/bin/bash

# Exit on any error
set -e

main() {
  docker-compose exec webp-to-gif bash -c "/app/scripts/convert_all_in_dir.sh ${*}"
}

main "$@"
