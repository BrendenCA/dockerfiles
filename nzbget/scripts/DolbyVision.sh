#!/bin/bash
#
# Dolby Vision post-processing script for NZBGet
#

##############################################################################
### NZBGET POST-PROCESSING SCRIPT                                          ###

# Remuxes MKV Dolby Vision, HDR10 files into MP4

### NZBGET POST-PROCESSING SCRIPT                                          ###
##############################################################################


POSTPROCESS_SUCCESS=93
POSTPROCESS_ERROR=94
MIN_FILE_SIZE=`expr 750 \* 1024`k  # 750MB
IMAGE_SUBFORMATS=( "hdmv_pgs_subtitle" )
FFMPEG_DEFAULT_LOGGING="-hide_banner -loglevel error"

if [[ $NZBPP_NZBNAME == *".DV."* || $NZBPP_NZBNAME == *".HDR10."* ]] && [[ $NZBPP_TOTALSTATUS == "SUCCESS" ]]; then
  filePath=$(find $NZBPP_DIRECTORY -name '*.mkv' -size +$MIN_FILE_SIZE | head -n 1)
  if [[ "${filePath}" != "" ]]; then
    cd $NZBPP_DIRECTORY

    isDvP7=$(ffprobe ${FFMPEG_DEFAULT_LOGGING} -select_streams v:0 -show_entries stream_side_data_list "${filePath}" | grep "dv_profile=7")
    if [ -z "$isDvP7" ]; then # Not DV P7
      echo "[DETAIL] Checking subtitles"
      subtitleStreams=`ffprobe ${FFMPEG_DEFAULT_LOGGING} -select_streams s -show_entries stream=index,codec_name -of csv=p=0 "${filePath}"`
      ignoreStreams=()
      while IFS=, read idx codec
      do
        if [[ " ${IMAGE_SUBFORMATS[*]} " =~ " ${codec} " ]]; then
          echo "[DETAIL] Found Image Subtitle ${idx}:${codec}"
          ignoreStreams+=(-map "-0:${idx}")
        fi
      done <<< "${subtitleStreams}"

      if [ -z "$ignoreStreams" ]; then
        echo "[DETAIL] Removing Subtitles: ${ignoreStreams[@]}"
      fi

      echo "[DETAIL] Remuxing to mp4"
      ffmpeg ${FFMPEG_DEFAULT_LOGGING} -i "${filePath}" -map 0 "${ignoreStreams[@]}" -c copy -scodec mov_text -strict -2 output.mp4

      if [ $? -eq 0 ]; then
        echo "[DETAIL] Cleaning up"
        rm "${filePath}"
        mv output.mp4 "${filePath%.*}.mp4"
      else
        echo "[ERROR] Remux failed"
        exit $POSTPROCESS_ERROR
      fi
    else
      echo "[DETAIL] Dolby Vision Profile 7"
      echo "[DETAIL] Demuxing mkv to DV Profile 8 HEVC"
      ffmpeg ${FFMPEG_DEFAULT_LOGGING} -i "${filePath}" -c:v copy -vbsf hevc_mp4toannexb -f hevc - | dovi_tool -m 2 convert --discard - -o BL_RPU.hevc

      echo "[DETAIL] Demuxing EAC3 from mkv"
      ffmpeg ${FFMPEG_DEFAULT_LOGGING} -i "${filePath}" -map 0:a:0 audio.eac3
      rm "${filePath}"
      mv audio.eac3 audio.ec3

      echo "[DETAIL] Remuxing HEVC, EAC3 to mp4"
      mp4muxer --dv-profile 8 --dv-bl-compatible-id 1 -i BL_RPU.hevc -i audio.ec3 -o output.mp4

      if [ $? -eq 0 ]; then
        echo "[DETAIL] Cleaning up"
        rm BL_RPU.hevc audio.ec3
        mv output.mp4 "${filePath%.*}.mp4"
      else
        echo "[ERROR] Remux failed"
        exit $POSTPROCESS_ERROR
      fi

    fi
  fi
fi
exit $POSTPROCESS_SUCCESS