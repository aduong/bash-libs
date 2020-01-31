#!/usr/bin/env bash
#
# reads in a JWT from STDIN and prints out its decoded parts

IFS=. read -r -a parts
echo '# Payload'
base64 -d <<< "${parts[1]}" 2> /dev/null | jq
echo '# Header'
base64 -d <<< "${parts[0]}" 2> /dev/null | jq
echo '# Signature'
fold <<< "${parts[2]}"
tr -- '-_' '+/' <<< "${parts[2]}" | base64 -d 2> /dev/null | hd
