#!/usr/bin/env zsh

cd $(dirname $0)

the_year=$(date +%Y)
the_month=$(date +%m)
the_day=$(date +%d)

d=$(date +"%Y-%m-%dT%H:%M:%S%z")
zipurl="http://zipperdog.dyndns.org/NWS"

wget_opts="--quiet -O-"

echo -n "Downloading images [$d]..."
c1out=camera1/$(date +%Y)/$(date +%m)/$(date +%d)
mkdir -p $c1out
wget ${=wget_opts} $zipurl/camera1.jpg > $c1out/camera1_${d}.jpg

echo -n .
c2out=camera2/$(date +%Y)/$(date +%m)/$(date +%d)
mkdir -p $c2out
wget ${=wget_opts} $zipurl/camera2.jpg > $c2out/camera2_${d}.jpg

echo -n .
c3out=camera3/$(date +%Y)/$(date +%m)/$(date +%d)
mkdir -p $c3out
wget ${=wget_opts} $zipurl/camera3.jpg > $c3out/camera3_${d}.jpg

echo done
