#!/bin/bash

# Сброс цвета
C_RESET='\e[0m'
# Цвет сообщения
C_MESSAGE='\e[0;36m'
# Цвет успешного выполнения
C_SUCCESS='\e[0;32m'
# Цвет ошибки
C_ERROR='\e[0;31m'
# Цвет команды
C_COMMAND='\e[0;95m'
# Цвет полужирного текста
C_TEXT_BOLD='\e[1;95m'

filename_in="$1" && shift
if [[ -z "${filename_in}" ]]; then
    echo -e "${C_ERROR}Использование скрипта: ${C_COMMAND}./script.sh <путь к исходному файлу с расширением> [0|1 - прозрачный ли фон] [0|1|2 - степень сжатия]${C_RESET}" >&2
    exit 1
fi

filename_out=$(basename "$filename_in" | sed -E 's/(.+)\.(.*+)/\1.gif/') || exit 1
if [[ "${filename_in}" == "${filename_out}" ]]; then
    filename_out="$filename_in.gif"
fi

is_background_alpha=${1:-1} && shift
is_optimize=${1:-1} && shift

palete_filename="pallete.png"
temp_directory="temp"
frame_filename="${temp_directory}/%05d.png"

if [ -d "${temp_directory}" ]; then
    rm -rf "${temp_directory}" || exit 1
fi
if [ ! -d "${temp_directory}" ]; then
    mkdir "${temp_directory}" || exit 1
fi

echo -e "${C_MESSAGE}Разбитие картинки на кадры...${C_RESET}"
ffmpeg --help &> /dev/null || (sudo apt update && sudo apt install ffmpeg -y) || exit 1
# Получение видимой обралсти кадров в формате "x1 y1 x2 y2"
crops=$(ffmpeg -i "${filename_in}" -vf cropdetect -f null - 2>&1 | awk '/crop=/' | sed -E 's/(.*)x1:([0-9]+) x2:([0-9]+) y1:([0-9]+) y2:([0-9]+)(.*)/\2 \4 \3 \5/')
min_x=$(echo -e "${crops}" | sort -t ' ' -n -k 1 | cut -d ' ' -f 1 | head -n 1)
min_y=$(echo -e "${crops}" | sort -t ' ' -n -k 2 | cut -d ' ' -f 2 | head -n 1)
max_x=$(echo -e "${crops}" | sort -t ' ' -n -k 3 -r | cut -d ' ' -f 3 | head -n 1)
max_y=$(echo -e "${crops}" | sort -t ' ' -n -k 4 -r | cut -d ' ' -f 4 | head -n 1)
echo -e "========================================"
echo -e "$crops"
echo -e "========================================"
echo -e "$crops"
echo -e "========================================"
echo -e "min_x=${min_x}"
echo -e "min_y=${min_y}"
echo -e "max_x=${max_x}"
echo -e "max_y=${max_y}"
echo -e "========================================"
((width = max_x - min_x + 1))
((height = max_y - min_y + 1))
if ((min_x < 0 || min_y < 0 || width <= 0 || height <= 0)); then
    echo -e "${C_ERROR}Не удалось обрезать картинку!${C_RESET}" >&2
    exit 1
fi
cropvalue="crop=${width}:${height}:${min_x}:${min_y}"
echo -e "${cropvalue}"
echo -e "========================================"

if ((is_background_alpha)); then
    ffmpeg -y -i "$filename_in" -vf "colorkey=0a0a0a:0.04" "${frame_filename}" || exit 1
    # ffmpeg -y -i "$filename_in" -vf "crop=300:300:300:0,colorkey=0a0a0a:0.04" "${frame_filename}" || exit 1
else
    ffmpeg -y -i "$filename_in" "${frame_filename}" || exit 1
fi
echo -e "${C_SUCCESS}Разбитие картинки на кадры: успешно!${C_RESET}"

echo -e "${C_MESSAGE}Создание палитры...${C_RESET}"
ffmpeg -y -i "$filename_in" -vf palettegen "${palete_filename}" || exit 1
echo -e "${C_SUCCESS}Создание палитры: успешно!${C_RESET}"

echo -e "${C_MESSAGE}Объединение прозрачных кадров в новое изображение...${C_RESET}"
ffmpeg -y -thread_queue_size 1024 -framerate 12 -i "${frame_filename}" -i "${palete_filename}" -lavfi paletteuse -gifflags 0 "$filename_out" || exit 1
echo -e "${C_SUCCESS}Объединение прозрачных кадров в новое изображение: успешно!${C_RESET}"

echo -e "${C_MESSAGE}Чистка временных файлов...${C_RESET}"
if [ -f "${palete_filename}" ]; then
    rm "${palete_filename}" || exit 1
fi
if [ -d "${temp_directory}" ]; then
    rm -rf "${temp_directory}" || exit 1
fi
echo -e "${C_SUCCESS}Чистка временных файлов: успешно!${C_RESET}"

if ((is_optimize > 0)); then
    echo -e "${C_MESSAGE}Сжатие полученного изображения...${C_RESET}"
    gifsicle --help &> /dev/null || (sudo apt update && sudo apt install gifsicle -y) || exit 1
    if ((is_optimize == 1)); then
        gifsicle -O3 --colors 256 --lossy=30 -i "$filename_out" -o "$filename_out" || exit 1
    else
        gifsicle -O3 --colors 64 --lossy=100 -i "$filename_out" -o "$filename_out" || exit 1
    fi
    echo -e "${C_SUCCESS}Сжатие полученного изображения: успешно!${C_RESET}"
fi

echo -e "${C_SUCCESS}Файл ${C_TEXT_BOLD}${filename_out}${C_SUCCESS} успешно создан!${C_RESET}"
