#!/bin/bash

filename="17.webp"
filename_out="out.gif"

# sudo apt update || exit 1
# sudo apt install ffmpeg gifsicle -y || exit 1
[ -d temp ] && rm -rf temp
[ ! -d temp ] && mkdir temp

# Разбиваем на кадры
ffmpeg -y -i "$filename" -vf colorkey=0a0a0a:0.1 temp/%05d.png

# ffmpeg -f webp -f lavfi -i color=00ff00 -i "$filename" -y \
#     -filter_complex "[0][1]scale2ref[bg][gif];[bg]setsar=1[bg];[bg][gif]overlay=shortest=1,scale=w='2*trunc(iw/2)':h='2*trunc(ih/2)'" \
#     -pix_fmt yuv420p -movflags frag_keyframe+empty_moov -movflags +faststart \
#     -crf 20 -b:v 500k -f mp4 animated.mp4
# Делаем каждый кадр прозрачным
# ffmpeg -i temp/%05d.png -vf colorkey=0a0a0a:0.1 temp/transparent_%05d.png
# Объединяем прозрачные кадры в новую гифку
# ffmpeg -y -thread_queue_size 32 -framerate 10 -i temp/transparent_%05d.png -i palette.png -lavfi paletteuse -gifflags 0 "$filename_out"

# Замена фона
# ffmpeg -y -f lavfi -i color=c=00ff00:s=540x303 -frames:v 1 bg.png
# ffmpeg -y -i temp/transparent_%05d.png -i bg.png -vsync 0 -filter_complex "[1:v][0:v]overlay[out]" -map "[out]" temp/combined_%05d.png
# ffmpeg -y -framerate 12 -i temp/combined_%05d.png -vf palettegen palette.png
# ffmpeg -y -thread_queue_size 32 -framerate 14 -i temp/combined_%05d.png -i palette.png -lavfi paletteuse final.gif

# exit 0

# # Разбиваем на кадры
# ffmpeg -i "$filename" -vsync 0 temp/%05d.png
# # Делаем каждый кадр прозрачным
# ffmpeg -i temp/%05d.png -vf colorkey=0a0a0a:0.1 temp/transparent_%05d.png
# # Объединяем прозрачные кадры в новую гифку
# ffmpeg -y -thread_queue_size 32 -framerate 10 -i temp/transparent_%05d.png -i palette.png -lavfi paletteuse -gifflags 0 "$filename_out"
# #

# # РАБОТАЕТ
# # ffmpeg -y -i "$filename" -vf palettegen palette.png || exit 1
# # ffmpeg -y -i "$filename" -i palette.png -filter_complex paletteuse -r 10 "$filename_out" || exit 1

# # ffmpeg -y -i "$filename" -vf palettegen=reserve_transparent=1 palette.png
# # ffmpeg -y -framerate 30 -i "$filename" -i palette.png -lavfi paletteuse=alpha_threshold=128 -gifflags -offsetting treegif.gif
# # ffmpeg -i "$filename_out" -filter_complex '[0]split[m][a];[a]geq='"'if(gt(lum(X,Y),16),255,0)'"',hue=s=0[al];[m][al]alphamerge[ovr];[0][ovr]overlay' output.gif

# # ffmpeg -y -i "$filename" -vf palettegen=reserve_transparent=1 palette.png
# # ffmpeg -y -i "$filename" -i palette.png -lavfi paletteuse=alpha_threshold=128 -gifflags -offsetting treegif.gif

# # Генерация видео
# # ffmpeg -y -i "$filename_out" -filter_complex \
# #     "[0]split[m][a];
# #  [a]geq='if(gt(lum(X,Y),16),255,0)',hue=s=0[al];
# #  [m][al]alphamerge[ovr];
# #  [0][ovr]overlay" \
# #     output.mp4
