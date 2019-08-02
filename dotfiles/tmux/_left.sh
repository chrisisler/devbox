#!/usr/bin/env bash

set -eu

_os() {
  local result="$(lsb_release --description | sed -e "s/^Description:\s\+//")"
  printf "[$result]"
}

tmuxlineLeft() {
  # _os
  continue
}
tmuxlineLeft
