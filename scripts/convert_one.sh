#!/bin/bash

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

  local directory_with_this_script
  directory_with_this_script="$(dirname "${BASH_SOURCE[0]}")"
  cd "${directory_with_this_script}/.."

  if [ ! -f "${filename_in}" ]; then
    echo -e "${C_ERROR}File ${C_TEXT_BOLD}${filename_in}${C_ERROR} does not exist!${C_RESET}" >&2
    return 1
  fi

  check_command ffmpeg
  check_command gifsicle

  echo -e "${C_MESSAGE}Getting frames info...${C_RESET}" >&2

  local is_webp_invalid=0

  local frames_info_raw
  frames_info_raw="$(webpinfo "${filename_in}")" || is_webp_invalid=1

  local framerate
  local final_duration
  if ((is_webp_invalid)); then
    echo -e "${C_ERROR}Warning! This webp image has invalid format and libwebp utils (webpinfo, anim_dump, etc.) can't process it. However, if this image does not contain ANIM nor ANMF, it still can be processed by ffmpeg. Processing with ffmpeg...${C_RESET}" >&2

    frames_info_raw="$(ffmpeg -i "${filename_in}" -f null /dev/null 2>&1)"
    framerate=$(echo "${frames_info_raw}" | grep 'Stream' | head -n 1 | sed -En 's/.*, ([0-9]+(\.[0-9]+)?) fps,.*/\1/p')
    final_duration=$(echo "${frames_info_raw}" | sed -En 's/^\s*Duration: ([0-9:.]+),.*$/\1/p')
  else
    local durations
    durations="$(echo "${frames_info_raw}" | sed -En 's/^\s*Duration: ([0-9]+)$/\1/p')"
    local duration_in_milliseconds=0
    local frames_count=0
    local duration
    for duration in ${durations}; do
      ((duration_in_milliseconds = duration_in_milliseconds + duration))
      ((frames_count = frames_count + 1))
    done

    # webp-image still can be not animated - in this case it has only one frame
    if ((duration_in_milliseconds == 0 || frames_count == 0)); then
      duration_in_milliseconds=1000
      frames_count=1
    fi

    echo -e "${C_SUCCESS}Frames info: Frames count: ${C_TEXT_BOLD}${frames_count}${C_SUCCESS}.${C_RESET}" >&2

    final_duration="${duration_in_milliseconds}ms"
    # To increase accuracy, we move 1000 from the denominator to the numerator
    framerate="$((frames_count * 1000 / duration_in_milliseconds))"
  fi
  echo -e "${C_SUCCESS}Frames info: Duration: ${C_TEXT_BOLD}${duration_in_milliseconds}ms${C_SUCCESS}.${C_RESET}" >&2
  echo -e "${C_SUCCESS}Calculated framerate: ${C_TEXT_BOLD}${framerate}${C_SUCCESS}.${C_RESET}" >&2

  local loops
  loops="$(echo "${frames_info_raw}" | sed -En 's/^\s+?Loop count\s+?:\s+?([0-9]+)$/\1/p')"
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

  echo -e "${C_MESSAGE}Splitting picture \"${filename_in}\" into frames...${C_RESET}" >&2
  if ((is_webp_invalid)); then
    if ((is_transparent)); then
      ffmpeg -y -i "${filename_in}" -vf colorkey=0a0a0a:0.04 "${frame_filename}" || exit 1
    else
      ffmpeg -y -i "${filename_in}" "${frame_filename}" || exit 1
    fi
  else
    anim_dump -folder "${temp_directory}" -prefix "" "${filename_in}"
  fi
  echo -e "${C_SUCCESS}Splitting a picture into frames: successful!${C_RESET}" >&2

  echo -e "${C_MESSAGE}Creating a palette...${C_RESET}" >&2
  ffmpeg -y -i "${frame_filename}" -vf palettegen "${palette_filename}"
  echo -e "${C_SUCCESS}Creating a palette: successful!${C_RESET}" >&2

  echo -e "${C_MESSAGE}Combining frames into a new image...${C_RESET}" >&2
  local transparent_args=()
  if ((is_transparent)); then
    transparent_args=(-i "${palette_filename}" -lavfi paletteuse)
  fi
  ffmpeg -y -thread_queue_size 1024 -framerate "${framerate}" -i "${frame_filename}" "${transparent_args[@]}" -t "${final_duration}" "${filename_out}"
  echo -e "${C_SUCCESS}Combining frames into a new image: successful!${C_RESET}" >&2

  echo -e "${C_MESSAGE}Cleaning temporary files...${C_RESET}" >&2
  if [ -d ${temp_directory} ]; then
    rm -rf "${temp_directory}"
  fi
  echo -e "${C_SUCCESS}Cleaning temporary files: successful!${C_RESET}" >&2

  if ((compression_level > 0)); then
    echo -e "${C_MESSAGE}Compression of the resulting image...${C_RESET}" >&2
    if ((compression_level == 1)); then
      gifsicle -O3 --colors 256 --lossy=30 -i "${filename_out}" -o "${filename_out}"
    else
      gifsicle -O3 --colors 64 --lossy=100 -i "${filename_out}" -o "${filename_out}"
    fi
    echo -e "${C_SUCCESS}Compression of the resulting image: successful!${C_RESET}" >&2
  fi

  echo -e "${C_SUCCESS}File ${C_TEXT_BOLD}${filename_out}${C_SUCCESS} successfully created!${C_RESET}" >&2
}

main "$@"
