#!/bin/bash

the_year=${the_year:-$(date +%Y)}
the_month=${the_month:-$(date +%m)}
the_day=${the_day:-$(date +%d)}
suffix=$the_year-$the_month-$the_day.mp4

cd $(dirname $0)

for cam in camera1 camera2 camera3; do
    ./time_lapse.sh $cam/dailies/damcamdaily-$cam-$suffix $(ls -1tr $cam/$the_year/$the_month/$the_day/*)
done

filter="[0]pad=iw*3[l];[l][1]overlay=w[x];[x][2]overlay=w*2"

ffmpeg -y \
    -i camera1/dailies/damcamdaily-camera1-$suffix \
    -i camera2/dailies/damcamdaily-camera2-$suffix \
    -i camera3/dailies/damcamdaily-camera3-$suffix \
    -filter_complex $filter \
    -vcodec libx264 \
    combined_dailes/damcamdaily-combined-$suffix
