#!/usr/bin/env bash

echo 'Devices are'
arecord -l
echo 'Using hw:1,0'
exec arecord -D hw:1,0 -f dat -c 1 -r 48000 "$@"
