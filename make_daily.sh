#!/usr/bin/env zsh

the_year=${the_year:-$(date +%Y)}
the_month=${the_month:-$(date +%m)}
the_day=${the_day:-$(date +%d)}
output=${output:-$the_year-$the_month-$the_day.mp4}

cd $(dirname $0)

for cam in camera1 camera2 camera3; do
    ./time_lapse.sh $cam/dailies/damcamdaily-$cam-$output $(ls -1tr $cam/$the_year/$the_month/$the_day/*)
done

cam1_imgs=()
cam2_imgs=()
cam3_imgs=()
for img in $(ls -1tr camera1/$the_year/$the_month/$the_day/*); do
    cam2_img=camera2/$the_year/$the_month/$the_day/camera2_${${img##*/}##*_}
    cam3_img=camera3/$the_year/$the_month/$the_day/camera3_${${img##*/}##*_}
    if [[ $(du $img | awk '{print $1}') -gt 0 && \
        $({ du $cam2_img 2>/dev/null || echo 0; } | awk '{print $1}') -gt 0 && \
        $({ du $cam3_img 2>/dev/null || echo 0; } | awk '{print $1}') -gt 0 ]]; then
        cam1_imgs+=($img)
        cam2_imgs+=($cam2_img)
        cam3_imgs+=($cam3_img)
    fi
done

filter="[0]pad=iw*3[l];[l][1]overlay=w[x];[x][2]overlay=w*2,scale=1080:202"

ffmpeg -y \
    -f image2pipe -vcodec mjpeg -r 15 -i <(cat ${cam2_imgs[@]}) \
    -f image2pipe -vcodec mjpeg -r 15 -i <(cat ${cam1_imgs[@]}) \
    -f image2pipe -vcodec mjpeg -r 15 -i <(cat ${cam3_imgs[@]}) \
    -filter_complex $filter \
    -vcodec libx264 \
    combined_dailies/damcamdaily-combined-$output
