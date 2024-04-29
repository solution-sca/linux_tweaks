#!/bin/bash

HOST=$1

BASE_DIR=~/media/
MNT=${BASE_DIR}/${HOST}
MNT=${MNT//\/\//\/}
if [ -z "$1" ]; then
    echo "No remote host given" >&2
    return 1
fi

if [ ! -e "${MNT}" ]; then 
    mkdir ${MNT}
elif [ ! -d "${MNT}" ]; then
    echo -e "${MNT} is not a directory" >&2
    return 1
fi

echo sshfs $HOST:/ $MNT >&2
sshfs $HOST:/ $MNT
res=$?
if [ $res -eq 0 ]; then
    echo -n pushd:\ 
    pushd $MNT
fi
return $res