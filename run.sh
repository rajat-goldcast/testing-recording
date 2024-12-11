#!/bin/bash
#!/usr/bin/env node
set -e


pulseaudio -D --exit-idle-time=-1 --disallow-exit
pacmd load-module module-null-sink sink_name=loopback
pacmd set-default-sink loopback

Xvfb :0 -ac -screen 0 1920x1080x24 -nolisten unix -nolisten tcp &

# nginx
node youtubevideo.js
node server.js
# DON'T REMOVE exec FROM THE COMMAND BELOW, needed for graceful shutdown
