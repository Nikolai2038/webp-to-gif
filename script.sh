#!/bin/bash

sudo apt install webp -y || exit 1
sudo apt install imagemagick-6.q16 -y || exit 1

DELAY=${DELAY:-10}
LOOP=${LOOP:-0}

r=$(realpath "$1") || exit 1
d=$(dirname "$r") || exit 1
pushd "$d" > /dev/null || exit 1
f=$(basename "$r") || exit 1
n=$(webpinfo -summary "$f" | grep frames | sed -e 's/.* \([0-9]*\)$/\1/') || exit 1
dur=$(webpinfo -summary "$f" | grep Duration | head -1 | sed -e 's/.* \([0-9]*\)$/\1/') || exit 1

if ((dur > 0)); then
    DELAY=dur
fi

pfx=$(echo -n "$f" | sed -e 's/^\(.*\).webp$/\1/') || exit 1
if [ -z "$pfx" ]; then
    pfx=$f
fi

echo "converting $n frames from $f
working dir $d
file stem '$pfx'"

for i in $(seq -f "%05g" 1 "$n"); do
    webpmux -get frame "$i" "$f" -o "$pfx.$i.webp" || exit 1
    dwebp "$pfx.$i.webp" -o "$pfx.$i.png" || exit 1
done

convert "$pfx.*.png" -delay $DELAY -loop "$LOOP" "$pfx.gif" || exit 1
rm "$pfx.[0-9]*.png" "$pfx.[0-9]*.webp" || exit 1
popd > /dev/null || exit 1 || exit 1
