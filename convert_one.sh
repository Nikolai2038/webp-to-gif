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

check_command() {
  local command="$1" && { shift || true; }
  local package="${1:-${command}}" && { shift || true; }
  if ! which "${command}" &> /dev/null; then
    if which apt-get &> /dev/null; then
      echo -e "${C_MESSAGE}Command ${C_TEXT_BOLD}${command}${C_MESSAGE} is not installed! It seems that you are using apt package manager. Script will try to install package ${C_TEXT_BOLD}${package}${C_MESSAGE}...${C_RESET}"
      if [ "$(id -u)" = "0" ]; then
        apt-get update && apt-get install -y "${package}"
      else
        sudo apt-get update && sudo apt-get install -y "${command}"
      fi
      echo -e "${C_SUCCESS}Command ${C_TEXT_BOLD}${command}${C_MESSAGE} successfully installed!${C_RESET}"
    else
      echo -e "${C_MESSAGE}Command ${C_TEXT_BOLD}${command}${C_MESSAGE} is not installed! See documentation on how to install it for your package manager.${C_RESET}"
    fi
  fi
}

main() {
  # Getting the name of the input file
  local filename_in="$1" && { shift || true; }
  if [ -z "${filename_in}" ]; then
    echo -e "${C_ERROR}Script usage: ${C_COMMAND}./script.sh <file_path> [0|1 - enable transparency] [0|1|2 - compression level]${C_RESET}" >&2
    return 1
  fi

  check_command webpmux libwebpmux3
  check_command ffmpeg
  check_command gifsicle

  local is_mux_supported=0
  local frames_info_raw
  frames_info_raw="$(webpmux -info "${filename_in}")" && is_mux_supported=1

  echo -e "${C_MESSAGE}Getting frames info...${C_RESET}"
  local duration_in_milliseconds=1000
  local frames_count=1
  local framerate=10
  local loops=0
  if ((is_mux_supported)); then
    echo -e "${C_MESSAGE}Raw frames info:${C_RESET}"
    echo "${frames_info_raw}" >&2

    local frames_info
    frames_info="$(echo "${frames_info_raw}" | sed -En '/^\s*[0-9]+:/p')"

    frames_count="$(echo "${frames_info}" | wc -l)"

    # Duration can (?) be different for each frame, so we sum it all up
    local durations_expression
    durations_expression="$(echo "${frames_info}" | awk '{print "+ " $7}')"
    eval "duration_in_milliseconds=\"\$((0 + ${durations_expression}))\""
    duration_in_milliseconds="$((duration_in_milliseconds))"

    # To increase accuracy, we move 1000 from the denominator to the numerator
    framerate="$((frames_count * 1000 / duration_in_milliseconds))"

    loops="$(echo "${frames_info_raw}" | sed -En 's/^.*?Loop count: ([0-9]+)$/\1/p')"
  else
    echo -e "${C_ERROR}Frames info: Duration: ${C_TEXT_BOLD}${duration_in_milliseconds}ms${C_SUCCESS}.${C_RESET}" >&2
  fi

  echo -e "${C_SUCCESS}Frames info: Duration: ${C_TEXT_BOLD}${duration_in_milliseconds}ms${C_SUCCESS}.${C_RESET}" >&2
  echo -e "${C_SUCCESS}Frames info: Frames count: ${C_TEXT_BOLD}${frames_count}${C_SUCCESS}.${C_RESET}"
  echo -e "${C_SUCCESS}Frames info: Framerate: ${C_TEXT_BOLD}${framerate}${C_SUCCESS}.${C_RESET}" >&2
  if ((loops == 0)); then
    echo -e "${C_SUCCESS}Frames info: Loops: ${C_TEXT_BOLD}infinite${C_SUCCESS}.${C_RESET}" >&2
  else
    echo -e "${C_SUCCESS}Frames info: Loops: ${C_TEXT_BOLD}${loops}${C_SUCCESS}.${C_RESET}" >&2
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
  local frame_filename="${temp_directory}/%04d.png"

  if [ -d "${temp_directory}" ]; then
    rm -rf "${temp_directory}"
  fi
  mkdir "${temp_directory}"

  echo -e "${C_MESSAGE}Splitting picture \"${filename_in}\" into frames...${C_RESET}"
  anim_dump -folder "${temp_directory}" -prefix "" "${filename_in}"
  echo -e "${C_SUCCESS}Splitting a picture into frames: successful!${C_RESET}"

  echo -e "${C_MESSAGE}Creating a palette...${C_RESET}"
  ffmpeg -y -i "${frame_filename}" -vf palettegen "${palette_filename}"
  echo -e "${C_SUCCESS}Creating a palette: successful!${C_RESET}"

  echo -e "${C_MESSAGE}Combining frames into a new image...${C_RESET}"
  if ((is_transparent)); then
    ffmpeg -y -thread_queue_size 1024 -framerate "${framerate}" -i "${frame_filename}" -i "${palette_filename}" -lavfi paletteuse -t "${duration_in_milliseconds}ms" "${filename_out}"
  else
    ffmpeg -y -thread_queue_size 1024 -framerate "${framerate}" -i "${frame_filename}" -t "${duration_in_milliseconds}ms" "${filename_out}"
  fi
  # ffmpeg -i "${filename_out}" -f null - | grep frame
  echo -e "${C_SUCCESS}Combining frames into a new image: successful!${C_RESET}"

  echo -e "${C_MESSAGE}Cleaning temporary files...${C_RESET}"
  if [ -d ${temp_directory} ]; then
    rm -rf "${temp_directory}"
  fi
  echo -e "${C_SUCCESS}Cleaning temporary files: successful!${C_RESET}"

  if ((compression_level > 0)); then
    echo -e "${C_MESSAGE}Compression of the resulting image...${C_RESET}"
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
