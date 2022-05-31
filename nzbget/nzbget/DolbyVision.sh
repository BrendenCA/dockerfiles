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

if [[ $NZBPP_NZBNAME == *".DV."* ]] && [[ $NZBPP_TOTALSTATUS == "SUCCESS" ]]; then
  filePath=$(find $NZBPP_DIRECTORY -name '*.mkv' -size +750M | head -n 1)
  if [[ $filePath != "" ]]; then
    workDir=$(mktemp -d)
    cd $workDir
    echo "[DETAIL] Extracting Video"
    ffmpeg -hide_banner -loglevel error -i $filePath -c copy video.hevc
    echo "[DETAIL] Extracting Audio"
    ffmpeg -hide_banner -loglevel error -i $filePath -c copy audio.eac3
    mv audio.eac3 audio.ec3
    echo "[DETAIL] Remuxing to mp4"
    mp4muxer --dv-profile 5 -i video.hevc -i audio.ec3 --media-lang eng -o outputfile.mp4
    mv outputfile.mp4 $NZBPP_DIRECTORY
    rm $filePath
    rm -r "$workDir"
  fi
fi
exit $POSTPROCESS_SUCCESS