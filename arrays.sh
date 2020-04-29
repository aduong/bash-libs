#!/usr/bin/env bash

# array_contains TARGET ELEMS...
# Succeeds iff TARGET is in ELEMS
array_contains() {
  local target=$1
  shift

  for x in "$@"; do
    if [[ "$x" == "$target" ]]; then
      return 0
    fi
  done
  return 1
}
