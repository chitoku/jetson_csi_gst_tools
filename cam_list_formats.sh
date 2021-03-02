#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo "Usage example: $0 -d /dev/video0 "
    exit 0
fi

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -d|--device)
    DEVICE="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

COMMAND="v4l2-ctl -d ${DEVICE} --list-formats-ext"
echo "###### [Executing the following command] ################"
echo "${COMMAND}"
echo "#########################################################"
${COMMAND}