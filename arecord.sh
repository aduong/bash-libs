#!/usr/bin/env bash

file=~/recordings/$(date -Iseconds | cut -c-19).flac
echo "Recording to $file"
rec "$file"
