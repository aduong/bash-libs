#!/usr/bin/env bash

file=~/recordings/$(date -Iseconds | cut -c-19).wav.xz
echo "Recording to $file"
arecord -f dat -c 1 -r 48000 | pv -cN in | xz | pv -cN out > "$file"
