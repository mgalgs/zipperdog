#!/bin/bash

output=$1
shift

for j in $*; do
    [[ $(du $j | awk '{print $1}')  -eq 0 ]] || {
        # echo $j 1>&2
        cat $j
    }
done | ffmpeg -f image2pipe -r 12 -vcodec mjpeg -i - -vcodec libx264 $output
