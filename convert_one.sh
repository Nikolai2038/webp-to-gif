#!/usr/bin/env bash

# Exit on any error
set -e

# Message colors
C_RESET='\e[0m'
C_MESSAGE='\e[0;36m'
C_SUCCESS='\e[0;32m'
C_ERROR='\e[0;31m'
C_COMMAND='\e[0;95m'
C_TEXT_BOLD='\e[1;95m'

main() {
  # Getting the name of the input file
  local filename_in="$1" && { shift || true; }
  if [ -z "${filename_in}" ]; then
    echo -e "${C_ERROR}Script usage: ${C_COMMAND}./script.sh <file_path> [0|1 - enable transparency] [0|1|2 - compression level]${C_RESET}" >&2
    return 1
  fi

  # Getting the name of the output file
  local filename_out
  filename_out="$(echo "$filename_in" | sed -E 's/(.+)\.(.*+)/\1.gif/')"
  if [ "${filename_in}" = "${filename_out}" ]; then
    filename_out="${filename_in}.gif"
  fi

  local is_transparent=${1:-1} && { shift || true; }
  local compression_level=${1:-1} && { shift || true; }

  # Temp directory will be used to store image frames
  local temp_directory="temp"
  # Palette's filename
  local palette_filename="${temp_directory}/palette.png"
  # Frame's filename pattern
  local frame_filename="${temp_directory}/%05d.png"

  if [ -d "${temp_directory}" ]; then
    rm -rf "${temp_directory}"
  fi
  mkdir "${temp_directory}"

  echo -e "${C_MESSAGE}Splitting picture \"${filename_in}\" into frames...${C_RESET}"
  local is_mux_supported=0
  if webpmux -info "${filename_in}" &> /dev/null; then
    is_mux_supported=1
  fi

  if ((is_mux_supported)); then
    local frames_count
    frames_count="$(webpmux -info "${filename_in}" | sed -En 's/^Number of frames: ([0-9]+)$/\1/p')"
    if [ -z "${frames_count}" ]; then
      echo -e "${C_ERROR}Variable ${C_TEXT_BOLD}frames_count${C_ERROR} is empty!${C_RESET}"
      return 1
    fi
    echo -e "${C_SUCCESS}Found ${C_TEXT_BOLD}${frames_count}${C_SUCCESS} frames!${C_RESET}"

    local frame_filename_webp="${temp_directory}/%05d.webp"

    local frame_number
    for ((frame_number = 1; frame_number <= frames_count; frame_number++)); do
      local frame_file_path_webp
      # shellcheck disable=SC2059
      frame_file_path_webp="$(printf "${frame_filename_webp}" "${frame_number}")"
      local frame_file_path
      # shellcheck disable=SC2059
      frame_file_path="$(printf "${frame_filename}" "${frame_number}")"

      # Get webp frame
      webpmux -get frame "${frame_number}" "${filename_in}" -o "${frame_file_path_webp}"

      # Convert webp frame to png
      dwebp "${frame_file_path_webp}" -o "${frame_file_path}"

      #    # Another solution (need modifications)
      #      if ((is_transparent)); then
      #        ffmpeg -y -i "${frame_file_path_webp}" -vf colorkey=0a0a0a:0.04 "${frame_file_path}"
      #      else
      #        ffmpeg -y -i "${frame_file_path_webp}" "${frame_file_path}"
      #      fi
    done
  else
    ffmpeg --help &> /dev/null || (echo -e "${C_MESSAGE}Package ${C_TEXT_BOLD}ffmpeg${C_MESSAGE} will be installed...${C_RESET}" && sudo apt update && sudo apt install ffmpeg -y)
    if ((is_transparent)); then
      ffmpeg -y -i "$filename_in" -vf colorkey=0a0a0a:0.04 "${frame_filename}"
    else
      ffmpeg -y -i "$filename_in" "${frame_filename}"
    fi
  fi
  echo -e "${C_SUCCESS}Splitting a picture into frames: successful!${C_RESET}"

  echo -e "${C_MESSAGE}Creating a palette...${C_RESET}"
  if ((is_mux_supported)); then
    ffmpeg -y -i ./temp/00001.png -vf palettegen "${palette_filename}"
  else
    ffmpeg -y -i "$filename_in" -vf palettegen "${palette_filename}"
  fi
  echo -e "${C_SUCCESS}Creating a palette: successful!${C_RESET}"

  echo -e "${C_MESSAGE}Getting the framerate...${C_RESET}"
  local framerate
  if ((is_mux_supported)); then
    # TODO: find framerate
    framerate=8
  else
    framerate=$(ffmpeg -i "${filename_in}" -f null /dev/null 2>&1 | grep 'Stream' | head -n 1 | sed -En 's/.*, ([0-9]+(\.[0-9]+)?) fps,.*/\1/p')
    if [ -z "${framerate}" ]; then
      echo -e "${C_ERROR}Variable ${C_TEXT_BOLD}framerate${C_ERROR} is empty!${C_RESET}"
      return 1
    fi
  fi
  echo -e "${C_MESSAGE}Framerate: ${C_TEXT_BOLD}${framerate}${C_MESSAGE}.${C_RESET}"

  echo -e "${C_MESSAGE}Combining frames into a new image...${C_RESET}"
  if ((is_mux_supported)); then
    ffmpeg -y -thread_queue_size 1024 -framerate "${framerate}" -i "${frame_filename}" "${filename_out}"
  else
    ffmpeg -y -thread_queue_size 1024 -framerate "${framerate}" -i "${frame_filename}" -i "${palette_filename}" -lavfi paletteuse "${filename_out}"
  fi
  echo -e "${C_SUCCESS}Combining frames into a new image: successful!${C_RESET}"

  echo -e "${C_MESSAGE}Cleaning temporary files...${C_RESET}"
  if [ -d ${temp_directory} ]; then
    rm -rf "${temp_directory}"
  fi
  echo -e "${C_SUCCESS}Cleaning temporary files: successful!${C_RESET}"

  if ((compression_level > 0)); then
    echo -e "${C_MESSAGE}Compression of the resulting image...${C_RESET}"
    gifsicle --help &> /dev/null || (echo -e "${C_MESSAGE}Package ${C_TEXT_BOLD}gifsicle${C_MESSAGE} will be installed...${C_RESET}" && sudo apt update && sudo apt install gifsicle -y)
    if ((compression_level == 1)); then
      gifsicle -O3 --colors 256 --lossy=30 -i "${filename_out}" -o "${filename_out}"
    else
      gifsicle -O3 --colors 64 --lossy=100 -i "${filename_out}" -o "${filename_out}"
    fi
    echo -e "${C_SUCCESS}Compression of the resulting image: successful!${C_RESET}"
  fi

  echo -e "${C_SUCCESS}File ${C_TEXT_BOLD}${filename_out}${C_SUCCESS} successfully created!${C_RESET}"
}

main "$@"
