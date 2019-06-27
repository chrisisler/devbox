#!/usr/bin/env bash

set -eu

_os() {
  local result="$(lsb_release --description | sed -e "s/^Description:\s\+//")"
  printf "[$result]"
}

_windows() {
  local out="$(tmux list-windows)"

  # local windows="$(printf "$out\n" | wc -l | xargs)"
  # [ "$windows" == "1" ] && exit 0 

  # local result="$(printf "$out" | awk '{ print $1, $2 }' | tr '\n' ' ' | sed -e "s/: / /g")"
  local result="$(printf "$out" | awk '{ print $2 }' | tr '\n' ' ' | xargs)"
  printf "[$result]"
}

tmuxlineLeft() {
  _os
  _windows
}
tmuxlineLeft
