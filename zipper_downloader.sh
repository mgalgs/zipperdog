#!/usr/bin/env zsh

cd $(dirname $0)

VERBOSE=${VERBOSE:-0}

d=$(date +"%Y-%m-%dT%H:%M:%S%z")
zipurl="http://zipperdog.dyndns.org/NWS"

wget_opts="--quiet -t 2 --connect-timeout=10 -O-"

[[ $VERBOSE -eq 0 ]] || echo -n "Downloading images [$d]..."
c1out=camera1/$(date +%Y)/$(date +%m)/$(date +%d)
mkdir -p $c1out
wget ${=wget_opts} $zipurl/camera1.jpg > $c1out/camera1_${d}.jpg

[[ $VERBOSE -eq 0 ]] || echo -n .
c2out=camera2/$(date +%Y)/$(date +%m)/$(date +%d)
mkdir -p $c2out
wget ${=wget_opts} $zipurl/camera2.jpg > $c2out/camera2_${d}.jpg

[[ $VERBOSE -eq 0 ]] || echo -n .
c3out=camera3/$(date +%Y)/$(date +%m)/$(date +%d)
mkdir -p $c3out
wget ${=wget_opts} $zipurl/camera3.jpg > $c3out/camera3_${d}.jpg

[[ $VERBOSE -eq 0 ]] || echo done
