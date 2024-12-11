#!/bin/bash
set -xe

FPS="30"
PIX_FMT="yuv420p"
GOP_SIZE=60
PRESET="14"
TUNE="ll"
RC="vbr"
CQ="19"
CODEC="h264_nvenc"
PROFILE="high"
PROBESIZE="50M"
DISPLAY=":0"

ffmpeg -hide_banner -y -hwaccel cuda -hwaccel_output_format cuda \
-f avfoundation -thread_queue_size 1024 -i  ":0" \
-video_size 1920x1080 -framerate $FPS -thread_queue_size 1024 -probesize $PROBESIZE \
-f x11grab -draw_mouse 0 -i $DISPLAY \
-c:v $CODEC -qp $CQ -tune $TUNE \
-preset $PRESET -pix_fmt $PIX_FMT -profile:v $PROFILE \
-g $GOP_SIZE -keyint_min $GOP_SIZE \
\
-map 1:v:0 -s:0 $V_SIZE_0 -maxrate:0 1.5M -bufsize:0 3M \
-map 1:v:0 -s:1 $V_SIZE_1 -maxrate:1 2.5M -bufsize:1 5M \
-map 1:v:0 -s:2 $V_SIZE_2 -maxrate:2 5.5M -bufsize:2 9M \
\
-map 0:a:0 -map 0:a:0 -map 0:a:0 \
-c:a "aac" \
-ar "48000" \
-ab "128k" \
-af "aresample=async=1:min_hard_comp=0.1:first_pts=0" \
stream.m3u8 2>&1 | tee -a ffmpeg.log