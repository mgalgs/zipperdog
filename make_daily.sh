#!/usr/bin/env zsh

the_year=${the_year:-$(date +%Y)}
the_month=${the_month:-$(date +%m)}
the_day=${the_day:-$(date +%d)}
output=${output:-$the_year-$the_month-$the_day.mp4}
do_cams=${do_cams:-1}
# do_3x1=${do_3x1:-1}
do_1top_2bottom=${do_1top_2bottom:-1}
verbose=${verbose:-0}
do_upload=${do_upload:-y}
venv=${venv:-~/virtualenvs/zipperdog/bin/activate}

cd $(dirname $0)

[[ $do_upload = y ]] && source $venv

vlog()
{
    [[ $verbose -eq 0 ]] || echo $*
}

if [[ $do_cams -eq 1 ]]; then
    for cam in camera1 camera2 camera3; do
        ./time_lapse.sh $cam/dailies/damcamdaily-$cam-$output $(ls -1tr $cam/$the_year/$the_month/$the_day/*)
        case $cam in;
            camera1) readable="Camera 1" ;;
            camera2) readable="Camera 2" ;;
            camera3) readable="Camera 3" ;;
        esac
        [[ $do_upload = y ]] && ./upload_video.py \
            --file $cam/dailies/damcamdaily-$cam-$output \
            --title "Hyrum Dam Cam $the_year-$the_month-$the_day $readable" \
            --noauth_local_webserver
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
    ffmpeg -y \
        -f image2pipe -vcodec mjpeg -r 15 -i <(cat ${cam1_imgs[@]}) \
        -f image2pipe -vcodec mjpeg -r 15 -i <(cat ${cam2_imgs[@]}) \
        -f image2pipe -vcodec mjpeg -r 15 -i <(cat ${cam3_imgs[@]}) \
        -loop 1 -i banner.jpg \
        -filter_complex $filter \
        -vcodec libx264 \
        $vidname
}

# filter_3x1="[1]pad=iw*3[left];[left][0]overlay=w[x];[x][2]overlay=w*2,scale=1920:-2"
# all even:
# filter_1top_2bottom="[1]scale=w=1920/2:h=-1, pad=w=1920:h=1080:y=1080/2 [left_bottom]; [2] scale=w=-1:h=1080/2 [right_bottom]; [left_bottom][right_bottom] overlay=x=1920/2:y=1080/2 [bottom]; [0] scale=w=-1:h=1080/2 [top_middle]; [bottom][top_middle] overlay=x=1920/4"

# bottoms small:
# rollin="(h/2)-(300 * ((cos(1/4*3.1459*t)) + 1))"
rollin="(h/2)-(500*((1/5)^t))"
# font="Sail-Regular.ttf"
font="Satisfy-Regular.ttf"
filter_1top_2bottom="[3] scale=h=1080:w=-1, pad=w=1920:h=1080, trim=end=4, drawtext=fontfile=${font}: fontsize=150: x=(w/2)-(tw/2): y=${rollin}: text=HyrumDamCam.com, setsar=sar=1/1, fade=type=out:start_time=3:duration=1 [title]; [1]scale=w=-1:h=440, pad=w=1920:h=1080:x=178:y=640 [left_bottom]; [2] scale=w=-1:h=440 [right_bottom]; [left_bottom][right_bottom] overlay=x=960:y=640 [bottom]; [0] scale=w=-1:h=640 [top_middle]; [bottom][top_middle] overlay=x=391, setsar=sar=1/1, fade=duration=0.25 [main]; [title][main] concat=n=2"


# [[ $do_3x1 -eq 1 ]] && ffmpeg_from_imgs $filter_3x1 combined_dailies/damcamdaily-combined-3x1-$output
[[ $do_1top_2bottom -eq 1 ]] && ffmpeg_from_imgs $filter_1top_2bottom combined_dailies/damcamdaily-combined-1top_2bottom-$output

[[ $do_upload = y ]] && ./upload_video.py \
    --file combined_dailies/damcamdaily-combined-1top_2bottom-$output \
    --title "Hyrum Dam Cam $the_year-$the_month-$the_day All Cameras" \
    --noauth_local_webserver
