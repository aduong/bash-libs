#!/usr/bin/env bash

# max string length of all arg strings
max_length() {
  local max=0
  for s in "$@"; do
    if [[ ${#s} -gt $max ]]; then
      max=${#s}
    fi
  done
  echo "$max"
}

# rename a bash function from src to dst
rename_func() {
  local src=$1
  local dst=$2
  copy_func "$src" "$dst"
  unset "$src"
}

# copies a bash function from src to dst
copy_func() {
  local src=$1
  local dst=$2

  eval "$dst () $(declare -f "$src" | tail -n+2)"
}

export _util_funcs=(max_length rename_func copy_func)
