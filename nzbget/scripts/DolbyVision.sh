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

if [[ $NZBPP_NZBNAME == *".DV."* || $NZBPP_NZBNAME == *".HDR10."* ]] && [[ $NZBPP_TOTALSTATUS == "SUCCESS" ]]; then
  filePath=$(find $NZBPP_DIRECTORY -name '*.mkv' -size +$MIN_FILE_SIZE | head -n 1)
  if [[ $filePath != "" ]]; then
    cd $NZBPP_DIRECTORY
    echo "[DETAIL] Remuxing to mp4"
    ffmpeg -hide_banner -loglevel error -i $filePath -map 0 -c copy -scodec mov_text -strict unofficial output.mp4
    echo "[DETAIL] Cleaning up"
    rm $filePath
    mv output.mp4 "${filePath%.*}.mp4"
  fi
fi
exit $POSTPROCESS_SUCCESS