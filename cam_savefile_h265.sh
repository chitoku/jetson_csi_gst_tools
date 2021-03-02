#!/bin/bash

function display_usage(){
    echo "Usage: $0 (options) outfile"
    echo "Options:"
    echo "   -i | --sensor-id    : Specify camera id (Default 0)"
    echo "   -m | --sensor-mode  : Specify sensor mode (Default 3)"
    echo "   -w | --width        : Encode width (Default 1920)"
    echo "   -h | --height       : Encode height (Default 1080) "
    echo "   -f | --framerate    : Encode framerate (Default 30)"
    echo "   -b | --bitrate      : Encode bitrate in bps (Default 8,000,000) "
    echo "   -t | --timeout      : Duration of recording in sec (Default: 60)"
    echo ""
    echo "   -fm | --flipmethod        : 0-none, 1-ccw90, 2-rotate180, 3-cw90,"
    echo "                               4-horizontal-flip, 5-upper-right-diagonal,"
    echo "                               6-vertical-flip, upper-left-diagonal"
    echo "   -wb | --whitebalance      : 0-off, 1-auto, 2-incandescent, 3-fluorescent "
    echo "                               4-warm-fluorescent, 5-daylight, 6-cloudy-daylight "
    echo "                               7-twilight, 8-shade, 9-manual" 
    echo "   -er | --exposuretimerange : Ajust exposure time range in nano sec"
    echo "   -gr | --grainrange        : Adjust gain range (ex. --gainrange \"1 16\")"
    echo "   -igr| --ispdigitalgrainrange : (ex. --ispdigitalgainrange \"1 8\" -> Range value from 1 to 256)"
    exit 0
}

if [[ $# -eq 0 ]] ; then
    display_usage
fi

PARAMS=""

while (( "$#" )); do
  case "$1" in
    -i|--sensor-id)
      SENSORID=$2
      shift 2
      ;;
    -m|--sensor-mode)
      SENSORMODE=$2
      shift 2
      ;;
    -w|--witdh)
      WIDTH=$2
      shift 2
      ;;
    -h|--height)
      HEIGHT=$2
      shift 2
      ;;
    -f|--framerate)
      FRAMERATE=$2
      shift 2
      ;;
    -b|--bitrate)
      BITRATE=$2
      shift 2
      ;;
    -t|--timeout)
      TIMEOUT=$2
      shift 2
      ;;
    -fm|--flipmethod)
      FLIPMETHOD=$2
      shift 2
      ;;
    -er|--exposurerange)
      EXPOSURERANGE=$2
      shift 2
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

FILENAME=${PARAMS:1}
if [[ -z ${FILENAME+x} || ${#FILENAME} -eq 0 || "$FILENAME" =~ ( ) ]]; then display_usage; fi

if [ -z ${SENSORID+x} ]; then CMD_SENSORID="sensor-id=0"; else CMD_SENSORID="sensor-id=${SENSORID}"; fi
if [ -z ${SENSORMODE+x} ]; then CMD_SENSORMODE="sensor-mode=3"; else CMD_SENSORMODE="sensor-mode=${SENSORMODE}"; fi
if [ -z ${WIDTH+x} ]; then CMD_WIDTH="(int)1920"; else CMD_WIDTH="(int)${WIDTH}"; fi
if [ -z ${HEIGHT+x} ]; then CMD_HEIGHT="(int)1080"; else CMD_HEIGHT="(int)${HEIGHT}"; fi
if [ -z ${FRAMERATE+x} ]; then CMD_FRAMERATE="(fraction)30/1"; else CMD_FRAMERATE="(fraction)${FRAMERATE}/1"; fi
if [ -z ${BITRATE+x} ]; then CMD_BITRATE="bitrate=8000000"; else CMD_BITRATE="bitrate=${BITRATE}"; fi
if [ -z ${TIMEOUT+x} ]; then CMD_TIMEOUT="timeout=60"; else CMD_TIMEOUT="timeout=${TIMEOUT}"; fi
if [ -z ${FLIPMETHOD+x} ]; then CMD_FLIPMETHOD="flip-method=0"; else CMD_FLIPMETHOD="flip-method=${FLIPMETHOD}"; fi
if [ -z ${EXPOSURERANGE+x} ]; then CMD_EXPOSURERANGE=""; else CMD_EXPOSURERANGE="exposuretimerange=\"${EXPOSURERANGE}\""; fi

COMMAND="gst-launch-1.0 nvarguscamerasrc ${CMD_SENSORID} ${CMD_SENSORMODE} ${CMD_TIMEOUT} ${CMD_EXPOSURERANGE} ! \
  'video/x-raw(memory:NVMM), format=(string)NV12, width=${CMD_WIDTH}, height=${CMD_HEIGHT}, framerate=${CMD_FRAMERATE}' ! \
  nvvidconv ${CMD_FLIPMETHOD} ! \
  nvv4l2h265enc ${CMD_BITRATE} ! \
  h265parse ! \
  qtmux ! \
  filesink location=$FILENAME -e"
echo "======= [Executing the following command] =============="
echo "${COMMAND}"
echo "========================================================"
bash -c "${COMMAND}"
