#!/usr/bin/env bash

# wait --times N --interval M [--quiet] CMD...
#
# wait until some condition (CMD) is true by invoking CMD up to N times with M time in between
# invocations. M is a time spec used by sleep. Also prints out what's going on but can be
# silenced with --quiet.
wait_until() {
  local quiet=
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --times)
        shift
        local times=$(($1))
        shift
        ;;
      --interval)
        shift
        local interval="$1"
        shift
        ;;
      --quiet)
        shift
        quiet=1
        ;;
      *)
        break
        ;;
    esac
  done

  local cmd=("$@")
  local count=0
  until "${cmd[@]}"; do
    count=$((count + 1))
    if [[ $count -ge $times ]]; then
      test $quiet || echo "Tried \"${cmd[*]}\" $count times unsuccesfully. Stopping." >&2
      return 1
    fi
    test $quiet || echo "Tried \"${cmd[*]}\" $count times." >&2
    sleep "$interval"
  done
}
