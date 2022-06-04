FROM alpine:3.14 as buildstage
RUN \
    echo "**** Install build packages ****" && \
        apk add --no-cache \
            git \
            make \
            g++ && \
    echo "**** Clone mp4muxer repo ****" && \
        git clone "https://github.com/DolbyLaboratories/dlb_mp4base.git" && \
    echo "**** Build mp4muxer ****" && \
        cd "/dlb_mp4base/make/mp4muxer/linux_amd64" && \
        make mp4muxer_release && \
        mv mp4muxer_release /mp4muxer && \
        chmod +x /mp4muxer

FROM linuxserver/nzbget:latest
COPY --from=buildstage /mp4muxer /usr/local/bin/mp4muxer
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
        chmod +x /usr/local/bin/dovi_tool