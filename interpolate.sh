#!/usr/bin/env bash

# Reads from STDIN and interpolates any variables provided by the environment
interpolate () {
	local line
	perl -pe 's/"/\\"/g' |
		while IFS='' read -r line; do
			eval "echo \"$line\""
		done
}
