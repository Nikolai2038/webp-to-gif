#!/bin/bash

filename="17.webp"
filename_out="out.gif"
filename_out_optimized="out_optimized.gif"
is_super_optimize=0
is_background_alpha=1

ffmpeg --help &> /dev/null || (sudo apt update && sudo apt install ffmpeg -y) || exit 1
gifsicle --help &> /dev/null || (sudo apt update && sudo apt install gifsicle -y) || exit 1
optipng --help &> /dev/null || (sudo apt update && sudo apt install optipng -y) || exit 1
[ -d temp ] && rm -rf temp || exit 1
[ ! -d temp ] && mkdir temp || exit 1

# Разбиваем на кадры
if ((is_background_alpha)); then
    ffmpeg -y -i "$filename" -vf colorkey=0a0a0a:0.04 temp/%05d.png || exit 1
else
    ffmpeg -y -i "$filename" temp/%05d.png || exit 1
fi

# Оптимизация PNG (не играет роли, так как потом оптимизируется GIF, который сам оптимизирует PNG внутри себя)
# optipng temp/*.png

# Создаём палитру
ffmpeg -y -i "$filename" -vf palettegen palette.png || exit 1

# Объединяем прозрачные кадры в новую гифку
ffmpeg -y -thread_queue_size 1024 -framerate 10 -i temp/%05d.png -i palette.png -lavfi paletteuse -gifflags 0 "$filename_out" || exit 1

# Оптимизация GIF
if ((is_super_optimize)); then
    gifsicle -O3 --colors 64 --lossy=100 -i "$filename_out" -o "$filename_out_optimized" || exit 1
else
    gifsicle -O3 --colors 256 --lossy=30 -i "$filename_out" -o "$filename_out_optimized" || exit 1
fi
