#!/usr/bin/env bash

# Reads from STDIN and interpolates any variables provided by the environment
interpolate () {
	local file="${1:-/dev/stdin}"
	local line
	perl -pe 's/"/\\"/g' "$file" |
		while IFS='' read -r line; do
			eval "echo \"$line\""
		done
}
