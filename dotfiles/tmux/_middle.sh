#!/usr/bin/env bash

set -eu

_windows() {
  local out="$(tmux list-windows)"
  local windows="$(printf "$out\n" | wc -l | xargs)"
  local result=""
  if [[ $windows -le 2  ]]; then
    local result="$(printf "$out" | awk '{ print $2 }' | tr '\n' ' ' | xargs)"
  else
    local result="$(printf "$out" | awk '{ print $1, $2 }' | tr '\n' ' ' | sed -e "s/: /:/g" | xargs)"
  fi
  printf "[$result]"
}

tmuxlineMiddle() {
  _windows
}
tmuxlineMiddle
