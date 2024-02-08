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

# Getting the name of the input file
filename_in="$1" && { shift || true; }
if [[ -z ${filename_in} ]]; then
  echo -e "${C_ERROR}Script usage: ${C_COMMAND}./script.sh <file_path> [0|1 - enable transparency] [0|1|2 - compression level]${C_RESET}" >&2
  exit 1
fi

# Getting the name of the output file
filename_out=$(echo "$filename_in" | sed -E 's/(.+)\.(.*+)/\1.gif/') || exit 1
if [[ ${filename_in} == "${filename_out}" ]]; then
  filename_out="${filename_in}.gif"
fi

is_transparent=${1:-1} && { shift || true; }
compression_level=${1:-1} && { shift || true; }

# Temp directory will be used to store image frames
temp_directory="temp"
# Pallete's filename
palete_filename="${temp_directory}/pallete.png"
# Frame's filename pattern
frame_filename="${temp_directory}/%05d.png"

if [[ -d ${temp_directory} ]]; then
  rm -rf "${temp_directory}" || exit 1
fi
mkdir "${temp_directory}" || exit 1

echo -e "${C_MESSAGE}Splitting picture \"${filename_in}\" into frames...${C_RESET}"
if webpmux -info "${filename_in}" &> /dev/null; then
  is_mux_supported=1
else
  is_mux_supported=0
fi

if ((is_mux_supported)); then
  frames_count="$(webpmux -info "${filename_in}" | sed -En 's/^Number of frames: ([0-9]+)$/\1/p')"
  if [ -z "${frames_count}" ]; then
    echo -e "${C_ERROR}Variable ${C_TEXT_BOLD}frames_count${C_ERROR} is empty!${C_RESET}"
    exit 1
  fi
  echo -e "${C_SUCCESS}Found ${C_TEXT_BOLD}${frames_count}${C_SUCCESS} frames!${C_RESET}"

  frame_filename_webp="${temp_directory}/%05d.webp"

  for ((frame_number = 1; frame_number <= frames_count; frame_number++)); do
    # shellcheck disable=SC2059
    frame_file_path_webp="$(printf "${frame_filename_webp}" "${frame_number}")"
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
  ffmpeg --help &> /dev/null || (echo -e "${C_MESSAGE}Package ${C_TEXT_BOLD}ffmpeg${C_MESSAGE} will be installed...${C_RESET}" && sudo apt update && sudo apt install ffmpeg -y) || exit 1
  if ((is_transparent)); then
    ffmpeg -y -i "$filename_in" -vf colorkey=0a0a0a:0.04 "${frame_filename}" || exit 1
  else
    ffmpeg -y -i "$filename_in" "${frame_filename}" || exit 1
  fi
fi
echo -e "${C_SUCCESS}Splitting a picture into frames: successful!${C_RESET}"

echo -e "${C_MESSAGE}Creating a palette...${C_RESET}"
if ((is_mux_supported)); then
  ffmpeg -y -i ./temp/00001.png -vf palettegen "${palete_filename}"
else
  ffmpeg -y -i "$filename_in" -vf palettegen "${palete_filename}"
fi
echo -e "${C_SUCCESS}Creating a palette: successful!${C_RESET}"

echo -e "${C_MESSAGE}Getting the framerate...${C_RESET}"
if ((is_mux_supported)); then
  # TODO: find framerate
  framerate=8
else
  framerate=$(ffmpeg -i "${filename_in}" -f null /dev/null 2>&1 | grep 'Stream' | head -n 1 | sed -En 's/.*, ([0-9]+(\.[0-9]+)?) fps,.*/\1/p') || exit 1
  if [[ -z ${framerate} ]]; then
    echo -e "${C_ERROR}Variable ${C_TEXT_BOLD}framerate${C_ERROR} is empty!${C_RESET}"
    exit 1
  fi
fi
echo -e "${C_MESSAGE}Framerate: ${C_TEXT_BOLD}${framerate}${C_MESSAGE}.${C_RESET}"

echo -e "${C_MESSAGE}Combining frames into a new image...${C_RESET}"
if ((is_mux_supported)); then
  ffmpeg -y -thread_queue_size 1024 -framerate "${framerate}" -i "${frame_filename}" "${filename_out}" || exit 1
else
  ffmpeg -y -thread_queue_size 1024 -framerate "${framerate}" -i "${frame_filename}" -i "${palete_filename}" -lavfi paletteuse "${filename_out}" || exit 1
fi
echo -e "${C_SUCCESS}Combining frames into a new image: successful!${C_RESET}"

echo -e "${C_MESSAGE}Cleaning temporary files...${C_RESET}"
if [[ -d ${temp_directory} ]]; then
  rm -rf "${temp_directory}" || exit 1
fi
echo -e "${C_SUCCESS}Cleaning temporary files: successful!${C_RESET}"

if ((compression_level > 0)); then
  echo -e "${C_MESSAGE}Compression of the resulting image...${C_RESET}"
  gifsicle --help &> /dev/null || (echo -e "${C_MESSAGE}Package ${C_TEXT_BOLD}gifsicle${C_MESSAGE} will be installed...${C_RESET}" && sudo apt update && sudo apt install gifsicle -y) || exit 1
  if ((compression_level == 1)); then
    gifsicle -O3 --colors 256 --lossy=30 -i "${filename_out}" -o "${filename_out}" || exit 1
  else
    gifsicle -O3 --colors 64 --lossy=100 -i "${filename_out}" -o "${filename_out}" || exit 1
  fi
  echo -e "${C_SUCCESS}Compression of the resulting image: successful!${C_RESET}"
fi

echo -e "${C_SUCCESS}File ${C_TEXT_BOLD}${filename_out}${C_SUCCESS} successfully created!${C_RESET}"
