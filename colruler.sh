#!/usr/bin/env bash
#
# prints a column ruler in the terminal allowing the user to easily determine column positioning

cols=$(tput cols)

output_row=0
for (( c=cols ; c > 0 ; c /= 10 )); do
	output_row=$((output_row + 1))
done

while [[ $output_row -gt 0 ]]; do
	chunk_size=$((10 ** (output_row - 1)))
	for (( i=0 ; i*chunk_size < cols; i += 1 )); do
		c=$((cols - i*chunk_size))
		if [[ $c -gt $chunk_size ]]; then
			c=$chunk_size
		fi
		printf "%-${c}d" $((i % 10))
	done
	printf '\n'
	output_row=$((output_row - 1))
done
