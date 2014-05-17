#!/bin/bash

output=$1
shift

echo "Saving time lapse to $output"

for j in $*; do
    [[ $(du $j | awk '{print $1}')  -eq 0 ]] || {
        # echo $j 1>&2
        cat $j
    }
done | ffmpeg -y -f image2pipe -vcodec mjpeg -r 15 -i - -pix_fmt yuv420p -vcodec libx264 $output
