#!/usr/bin/env zsh

cd $(dirname $0)

VERBOSE=${VERBOSE:-0}

say()
{
    [[ $VERBOSE -eq 0 ]] || echo $*
}

d=$(date +"%Y-%m-%dT%H:%M:%S%z")
zipurl="http://www.hyrumdamcam.com/Images"

wget_opts="--quiet -t 2 --connect-timeout=10 -O-"

say -n "Downloading images [$d]..."
c1out=camera1/$(date +%Y)/$(date +%m)/$(date +%d)
mkdir -p $c1out
wget ${=wget_opts} $zipurl/hyrum_dam_w.jpg > $c1out/camera1_${d}.jpg

say -n .
c2out=camera2/$(date +%Y)/$(date +%m)/$(date +%d)
mkdir -p $c2out
wget ${=wget_opts} $zipurl/hyrum_dam_ne.jpg > $c2out/camera2_${d}.jpg

say -n .
c3out=camera3/$(date +%Y)/$(date +%m)/$(date +%d)
mkdir -p $c3out
wget ${=wget_opts} $zipurl/hyrum_dam_se.jpg > $c3out/camera3_${d}.jpg

say -n .
c4out=camera4/$(date +%Y)/$(date +%m)/$(date +%d)
mkdir -p $c4out
wget ${=wget_opts} $zipurl/hyrum_dam_s.jpg > $c4out/camera4_${d}.jpg

say -n .
c5out=camera5/$(date +%Y)/$(date +%m)/$(date +%d)
mkdir -p $c5out
wget ${=wget_opts} $zipurl/hyrum_dam_sw.jpg > $c5out/camera5_${d}.jpg

say done
