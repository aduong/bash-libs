#!/usr/bin/env bash

set -o errexit -o pipefail -o nounset

cat -n ~/.bash_history | sort -k2 -k1,1nr | uniq -f1 | sort -n | cut -f2- > ~/.bash_history.tmp
mv ~/.bash_history{.tmp,}
