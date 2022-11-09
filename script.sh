#!/bin/bash

filename="17.webp"
filename_out="out.gif"

sudo apt update || exit 1
sudo apt install ffmpeg gifsicle -y || exit 1

[ ! -d temp ] && mkdir temp
# Разбиваем на кадры
ffmpeg -i "$filename" -vsync 0 temp/%05d.png
# Делаем каждый кадр прозрачным
ffmpeg -i temp/%05d.png -vf colorkey=0a0a0a:0.1 temp/transparent_%03d.png
# Объединяем прозрачные кадры в новую гифку
ffmpeg -y -thread_queue_size 32 -framerate 14 -i temp/transparent_%03d.png -i palette.png -lavfi paletteuse -gifflags 0 final.gif
#

# РАБОТАЕТ
# ffmpeg -y -i "$filename" -vf palettegen palette.png || exit 1
# ffmpeg -y -i "$filename" -i palette.png -filter_complex paletteuse -r 10 "$filename_out" || exit 1

# ffmpeg -y -i "$filename" -vf palettegen=reserve_transparent=1 palette.png
# ffmpeg -y -framerate 30 -i "$filename" -i palette.png -lavfi paletteuse=alpha_threshold=128 -gifflags -offsetting treegif.gif
# ffmpeg -i "$filename_out" -filter_complex '[0]split[m][a];[a]geq='"'if(gt(lum(X,Y),16),255,0)'"',hue=s=0[al];[m][al]alphamerge[ovr];[0][ovr]overlay' output.gif

# ffmpeg -y -i "$filename" -vf palettegen=reserve_transparent=1 palette.png
# ffmpeg -y -i "$filename" -i palette.png -lavfi paletteuse=alpha_threshold=128 -gifflags -offsetting treegif.gif

# Генерация видео
# ffmpeg -y -i "$filename_out" -filter_complex \
#     "[0]split[m][a];
#  [a]geq='if(gt(lum(X,Y),16),255,0)',hue=s=0[al];
#  [m][al]alphamerge[ovr];
#  [0][ovr]overlay" \
#     output.mp4
