#!/usr/bin/env bash

# Exit on any error
set -e

main() {
  local directory_with_this_script
  directory_with_this_script="$(dirname "${BASH_SOURCE[0]}")"

  docker-compose exec webp-to-gif-service bash -c '
    mkdir --parents frames && \
    cd frames && \
    anim_dump ../data/examples/07_anisticker.webp && \
    cd .. && \
    duration="$(webpmux -info ./data/examples/07_anisticker.webp | head -n 6 | tail -n 1)" && \
    echo $duration
    ffmpeg -framerate 10 -i frames/dump_%04d.png ./data/examples/07_anisticker.gif
  '
}

main "$@"
