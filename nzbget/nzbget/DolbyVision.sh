#!/bin/bash
#
# Dolby Vision post-processing script for NZBGet
#

##############################################################################
### NZBGET POST-PROCESSING SCRIPT                                          ###

# Remuxes MKV Dolby Vision files into MP4

### NZBGET POST-PROCESSING SCRIPT                                          ###
##############################################################################


POSTPROCESS_SUCCESS=93
POSTPROCESS_ERROR=94
MIN_FILE_SIZE=`expr 750 \* 1024`k  # 750MB

if [[ $NZBPP_NZBNAME == *".DV."* ]] && [[ $NZBPP_TOTALSTATUS == "SUCCESS" ]]; then
  filePath=$(find $NZBPP_DIRECTORY -name '*.mkv' -size +$MIN_FILE_SIZE | head -n 1)
  if [[ $filePath != "" ]]; then
    cd $NZBPP_DIRECTORY
    echo "[DETAIL] Extracting Video"
    ffmpeg -hide_banner -loglevel error -i $filePath -c copy video.hevc
    echo "[DETAIL] Extracting Audio"
    ffmpeg -hide_banner -loglevel error -i $filePath -c copy audio.eac3
    rm $filePath
    mv audio.eac3 audio.ec3
    echo "[DETAIL] Remuxing to mp4"
    mp4muxer --dv-profile 5 -i video.hevc -i audio.ec3 --media-lang eng -o outputfile.mp4
    echo "[DETAIL] Cleaning up"
    rm video.hevc
    rm audio.ec3
    echo "[DETAIL] Renaming output file"
    mv outputfile.mp4 "${filePath%.*}.mp4"
  fi
fi
exit $POSTPROCESS_SUCCESS