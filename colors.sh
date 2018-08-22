#!/usr/bin/env bash

# echos arguments with color
# example: echo_color 28 this is green
echo_color() {
	local color="$1"
	shift
	echo -n -e "\e[38;5;${color}m"
	echo -n "$@"
	echo -e '\e[0m'
}

echo_green () {
	echo_color 28 "$@"
}

echo_red () {
	echo_color 160 "$@"
}
