ffmpeg -hide_banner -y -hwaccel cuda -hwaccel_output_format cuda \
-f pulse -thread_queue_size 1024 -i loopback.monitor \
-video_size 1920x1080 -framerate $FPS -thread_queue_size 1024 -probesize $PROBESIZE \
-f x11grab -draw_mouse 0 -i $DISPLAY \
-c:v $CODEC -crf 19 -preset p5 -pix_fmt $PIX_FMT -profile:v $PROFILE \
-g $GOP_SIZE -keyint_min $GOP_SIZE \
-c:a aac -ar 48000 -ab 128k \
-af "aresample=async=1:min_hard_comp=0.1:first_pts=0" \
$OUTPUT_FILE 2>&1 | tee -a ffmpeg.log