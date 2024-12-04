ffmpeg -hide_banner \
-f pulse -thread_queue_size 1024 -i loopback.monitor \
\
-map 0:a:0 \
-c:a "aac" \
-ar "48000" \
-ab "128k" \
-af "aresample=async=1:min_hard_comp=0.1:first_pts=0" \
\
output.aac
