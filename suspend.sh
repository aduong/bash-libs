#!/usr/bin/env bash

script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

pkill reflex
pkill kubectl
systemctl suspend
