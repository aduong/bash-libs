#!/usr/bin/env bash

# max string length of all arg strings
max_length () {
	local max=0
	for s in "$@"; do
		if [[ ${#s} -gt $max ]]; then
			max=${#s}
		fi
	done
	echo "$max"
}
