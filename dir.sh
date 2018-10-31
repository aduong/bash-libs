#!/usr/bin/env bash

# successful iff one can `mkdir -p` on the argument
is_mkdirable () {
	local prefix="${1:-/}"
	if [[ -d "$prefix" ]]; then
		# already exists, no problem
		return 0
	fi

	# terminates because every iteration does `dirname prefix`
	# and eventually we get / which for sure exists and _may_ be writable
	while true; do
		if [[ -d $prefix && -w $prefix ]]; then
			# writable prefix
			return 0
		elif [[ -e $prefix ]]; then
			# not a directory or maybe not writeable
			return 1
		fi
		prefix=$(dirname "$prefix")
	done
}
