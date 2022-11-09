#!/bin/bash

filename="17.webp"

sudo apt update || exit 1
sudo apt install ffmpeg gifsicle -y || exit 1

ffmpeg -y -i "$filename" -vf palettegen palette.png || exit 1
ffmpeg -y -i "$filename" -i palette.png -filter_complex paletteuse -r 10 out.gif || exit 1
