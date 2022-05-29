FROM linuxserver/nzbget:latest

RUN \
    echo "**** Install ffmpeg, gcompat ****" && \
    apk add --no-cache \
        ffmpeg  \
        gcompat && \
    echo "**** Install mp4muxer ****" && \
    wget "https://github.com/DolbyLaboratories/dlb_mp4base/raw/master/bin/mp4muxer" \
        -O /usr/local/bin/mp4muxer && \
    chmod +x /usr/local/bin/mp4muxer