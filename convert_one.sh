#!/usr/bin/env bash

# Message colors
C_RESET='\e[0m'
C_MESSAGE='\e[0;36m'
C_SUCCESS='\e[0;32m'
C_ERROR='\e[0;31m'
C_COMMAND='\e[0;95m'
C_TEXT_BOLD='\e[1;95m'

# Getting the name of the input file
filename_in="$1" && shift
if [[ -z "${filename_in}" ]]; then
    echo -e "${C_ERROR}Script usage: ${C_COMMAND}./script.sh <file_path> [0|1 - enable transparency] [0|1|2 - compression level]${C_RESET}" >&2
    exit 1
fi

# Getting the name of the output file
filename_out=$(echo "$filename_in" | sed -E 's/(.+)\.(.*+)/\1.gif/') || exit 1
if [[ "${filename_in}" == "${filename_out}" ]]; then
    filename_out="$filename_in.gif"
fi

is_transparent=${1:-1} && shift
compression_level=${1:-1} && shift

palete_filename="pallete.png"
temp_directory="temp"
frame_filename="${temp_directory}/%05d.png"

# Temp dir will be used to store image frames
if [ -d "${temp_directory}" ]; then
    rm -rf "${temp_directory}" || exit 1
fi
if [ ! -d "${temp_directory}" ]; then
    mkdir "${temp_directory}" || exit 1
fi

echo -e "${C_MESSAGE}Splitting a picture into frames...${C_RESET}"
ffmpeg --help &> /dev/null || (sudo apt update && sudo apt install ffmpeg -y) || exit 1
if ((is_transparent)); then
    ffmpeg -y -i "$filename_in" -vf colorkey=0a0a0a:0.04 "${frame_filename}" || exit 1
else
    ffmpeg -y -i "$filename_in" "${frame_filename}" || exit 1
fi
echo -e "${C_SUCCESS}Splitting a picture into frames: successful!${C_RESET}"

echo -e "${C_MESSAGE}Creating a palette...${C_RESET}"
ffmpeg -y -i "$filename_in" -vf palettegen "${palete_filename}" || exit 1
echo -e "${C_SUCCESS}Creating a palette: successful!${C_RESET}"

echo -e "${C_MESSAGE}Combining transparent frames into a new image...${C_RESET}"
ffmpeg -y -thread_queue_size 1024 -framerate 10 -i "${frame_filename}" -i "${palete_filename}" -lavfi paletteuse -gifflags 0 "$filename_out" || exit 1
echo -e "${C_SUCCESS}Combining transparent frames into a new image: successful!${C_RESET}"

echo -e "${C_MESSAGE}Cleaning temporary files...${C_RESET}"
if [ -f "${palete_filename}" ]; then
    rm "${palete_filename}" || exit 1
fi
if [ -d "${temp_directory}" ]; then
    rm -rf "${temp_directory}" || exit 1
fi
echo -e "${C_SUCCESS}Cleaning temporary files: successful!${C_RESET}"

if ((compression_level > 0)); then
    echo -e "${C_MESSAGE}Compression of the resulting image...${C_RESET}"
    gifsicle --help &> /dev/null || (sudo apt update && sudo apt install gifsicle -y) || exit 1
    if ((compression_level == 1)); then
        gifsicle -O3 --colors 256 --lossy=30 -i "$filename_out" -o "$filename_out" || exit 1
    else
        gifsicle -O3 --colors 64 --lossy=100 -i "$filename_out" -o "$filename_out" || exit 1
    fi
    echo -e "${C_SUCCESS}Compression of the resulting image: successful!${C_RESET}"
fi

echo -e "${C_SUCCESS}File ${C_TEXT_BOLD}${filename_out}${C_SUCCESS} successfully created!${C_RESET}"
