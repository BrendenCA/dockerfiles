FROM alpine:3.15 as buildstage
RUN \
    echo "**** Install build packages ****" && \
        apk add --no-cache \
            git \
            make \
            g++ \
            zlib-dev && \
    echo "**** Clone gpac repo ****" && \
        git clone "https://github.com/gpac/gpac.git" && \
    echo "**** Build gpac ****" && \
        cd "gpac" && \
        git checkout "v2.0.0" && \
        ./configure && \
        make -j4 && \
        mv bin/gcc/ /gpac_bin

FROM linuxserver/nzbget:latest
COPY --from=buildstage /gpac_bin /gpac_bin
RUN \
    echo "**** Install ffmpeg ****" && \
        wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz && \
        tar xf ffmpeg*.tar.xz && \
        mv ffmpeg-*-static/ffmpeg ffmpeg-*-static/ffprobe /usr/local/bin/ && \
        rm -rf ffmpeg-*-static ffmpeg-*-static.tar.xz && \
        chmod +x /usr/local/bin/ffmpeg && \
        chmod +x /usr/local/bin/ffprobe && \
    echo "**** Install dovi_tool ****" && \
        wget "https://github.com/quietvoid/dovi_tool/releases/download/1.5.3/dovi_tool-1.5.3-x86_64-unknown-linux-musl.tar.gz" && \
        tar xf dovi_tool*.tar.gz && \
        mv ./dovi_tool /usr/local/bin/ && \
        rm -rf dovi_tool*.tar.gz && \
        chmod +x /usr/local/bin/dovi_tool && \
    echo "**** Install MP4Box ****" && \
        ln -s /gpac_bin/MP4Box /usr/local/bin/MP4Box