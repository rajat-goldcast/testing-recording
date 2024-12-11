FROM --platform=linux/amd64 nginx-base AS nginx-bin
FROM --platform=linux/amd64 recorder-base AS builder
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all

COPY --from=nginx-bin --chown=$USERNAME:$USERNAME /usr/local/nginx /usr/local/nginx
COPY --from=nginx-bin --chown=$USERNAME:$USERNAME /usr/local/sbin/nginx /usr/local/sbin/nginx
COPY --from=nginx-bin --chown=$USERNAME:$USERNAME /etc/nginx /etc/nginx
COPY --from=nginx-bin --chown=$USERNAME:$USERNAME /var/log/nginx /var/log/nginx
COPY --from=nginx-bin --chown=$USERNAME:$USERNAME /var/run/nginx /var/run/nginx
COPY --from=nginx-bin --chown=$USERNAME:$USERNAME /tmp/nginx-client-body /tmp/nginx-client-body
RUN nginx -t

RUN apt update && apt install -y \
  fonts-noto

RUN apt-get install -y wget
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install -y ./google-chrome-stable_current_amd64.deb

WORKDIR /home/app

COPY package.json package-lock.json /home/app/
COPY --chown=$USERNAME:$USERNAME . /home/app/

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
RUN npm install

ENV DISPLAY :0

ENTRYPOINT ["/home/app/run.sh"]
