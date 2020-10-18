#!/usr/bin/env bash

log() {
  echo "$@"
}

calc_int() {
  python -c "print(int(round($*)))"
}

laptop_display_name=eDP-1-1
dp_display_name=DP-1-1

screen_on() {
  xrandr --output $laptop_display_name --auto --primary --output $dp_display_name --right-of $laptop_display_name --auto
}

screen_off() {
  xrandr --output $dp_display_name --off
}

screen_auto() {
  export XAUTHORITY=${XAUTHORITY:-/home/aduong/.Xauthority}
  export DISPLAY=${DISPLAY:-:0}

  xrandr_out=$(xrandr -q)
  laptop_display_connected=$(grep -q "$laptop_display_name connected" <<< "$xrandr_out" && echo true)
  hdmi_display_connected=$(grep -q "$hdmi_display_name connected" <<< "$xrandr_out" && echo true)
  dp_display_connected=$(grep -q "$dp_display_name connected" <<< "$xrandr_out" && echo true)
  num_displays_connected=$(grep -c ' connected ' <<< "$xrandr_out")

  log "laptop_display_connected=$laptop_display_connected"
  log "hdmi_display_connected=$hdmi_display_connected"
  log "dp_display_connected=$dp_display_connected"
  log "num_displays_connected=$num_displays_connected"

  if [[ $laptop_display_connected == true && $hdmi_display_connected == true && $dp_display_connected == true ]]; then
    log "turning screens on"
    screen_on
    exit
  fi

  if [[ $laptop_display_connected == true && $num_displays_connected -lt 3 ]]; then
    log "turning screens off"
    screen_off
    exit
  fi
}

if [[ $# -eq 0 ]]; then
  screen_auto
  exit
fi

case "$1" in
  on)
    screen_on
    ;;
  off)
    screen_off
    ;;
  *)
    echo "USAGE: $0 [on|off]"
    exit 1
    ;;
esac
