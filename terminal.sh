#!/usr/bin/env bash

# Sets the window title and icon name to the passed arguments
title() {
  echo -e -n "\033]0;$*\007"
}
