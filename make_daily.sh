#!/usr/bin/env zsh

the_year=${the_year:-$(date +%Y)}
the_month=${the_month:-$(date +%m)}
the_day=${the_day:-$(date +%d)}
output=${output:-$the_year-$the_month-$the_day.mp4}
do_cams=${do_cams:-1}
do_3x1=${do_3x1:-1}
# do_1top_2bottom=${do_1top_2bottom:-1}
verbose=${verbose:-0}

cd $(dirname $0)

vlog()
{
    [[ $verbose -eq 0 ]] || echo $*
}

if [[ $do_cams -eq 1 ]]; then
    for cam in camera1 camera2 camera3; do
        ./time_lapse.sh $cam/dailies/damcamdaily-$cam-$output $(ls -1tr $cam/$the_year/$the_month/$the_day/*)
    done
fi

iter=/
vlog -n "Building image lists $iter"
cam1_imgs=()
cam2_imgs=()
cam3_imgs=()
for img in $(ls -1tr camera1/$the_year/$the_month/$the_day/*); do
    case $iter in;
        "/") iter="-"; ;;
        "-") iter="\\"; ;;
        "\\") iter="|"; ;;
        "|") iter="/"; ;;
    esac
    vlog -n "\b$iter"
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
vlog -e " Done\n"

ffmpeg_from_imgs()
{
    filter="$1"
    vidname="$2"
    ffmpeg -y -t 2 \
        -f image2pipe -vcodec mjpeg -r 15 -i <(cat ${cam1_imgs[@]}) \
        -f image2pipe -vcodec mjpeg -r 15 -i <(cat ${cam2_imgs[@]}) \
        -f image2pipe -vcodec mjpeg -r 15 -i <(cat ${cam3_imgs[@]}) \
        -filter_complex $filter \
        -vcodec libx264 \
        combined_dailies/$vidname
}

filter_3x1="[1]pad=iw*3[left];[left][0]overlay=w[x];[x][2]overlay=w*2,scale=1920:-2"
# filter_1top_2bottom="[0]pad=iw*2[left];[1]scale=-2:ih/2,pad=height=ih*2[small1];[2]scale=-2:ih/2,pad=height=ih*2:y=ih[small2];[small2][small1]overlay[smalls];[left][smalls]overlay=main_w,scale=1920:-2"

[[ $do_3x1 -eq 1 ]] && ffmpeg_from_imgs $filter_3x1 damcamdaily-combined-3x1-$output
# [[ $do_1top_2bottom -eq 1 ]] && ffmpeg_from_imgs $filter_1top_2bottom damcamdaily-combined-1top_2bottom-$output
