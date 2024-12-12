#!/bin/bash
set -xe
FPS="30"
PIX_FMT="yuv420p"
GOP_SIZE=60
PRESET="14"
TUNE="ll"
CQ="19"
CODEC="h264_nvenc"
PROFILE="high"
PROBESIZE="50M"
DISPLAY=":0"
OUTPUT_FILE="recording.mp4"

ffmpeg -hide_banner -y -hwaccel cuda -hwaccel_output_format cuda \
-f avfoundation -thread_queue_size 1024 -i ":0" \
-video_size 1920x1080 -framerate $FPS -thread_queue_size 1024 -probesize $PROBESIZE \
-f x11grab -draw_mouse 0 -i $DISPLAY \
-c:v $CODEC -qp $CQ -tune $TUNE \
-preset $PRESET -pix_fmt $PIX_FMT -profile:v $PROFILE \
-g $GOP_SIZE -keyint_min $GOP_SIZE \
-c:a aac -ar 48000 -ab 128k \
-af "aresample=async=1:min_hard_comp=0.1:first_pts=0" \
$OUTPUT_FILE 2>&1 | tee -a ffmpeg.log