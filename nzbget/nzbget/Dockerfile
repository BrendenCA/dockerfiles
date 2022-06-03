FROM linuxserver/nzbget:latest

RUN \
    echo "**** Install ffmpeg ****" && \
        wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz && \
        tar xf ffmpeg*.tar.xz && \
        mv ffmpeg-*-static/ffmpeg ffmpeg-*-static/ffprobe /usr/bin/ && \
        rm -rf ffmpeg-*-static ffmpeg-*-static.tar.xz