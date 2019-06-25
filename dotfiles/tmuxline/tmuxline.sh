#!/usr/bin/env bash

set -eu

_tmuxlineInfo() {
  local windows="$(tmux list-windows | wc -l | tr -d ' ')W"
  local sessions="$(tmux list-sessions | wc -l | tr -d ' ')S"
  printf "[$windows $sessions]"
}

_containerId() {
  local result="ID: "$(uname -n)""
  printf "[$result]"
}

_disk() {
  local result="Disk"
  printf "[$result]"
}

_windows() {
  local out="$(tmux list-windows)"

  local windows="$(printf "$out\n" | wc -l | xargs)"
  # [ "$windows" == "1" ] && exit 0 

  # local result="$(printf "$out" | awk '{ print $1, $2 }' | tr '\n' ' ' | sed -e "s/: / /g")"
  local result="$(printf "$out" | awk '{ print $2 }' | tr '\n' ' ' | xargs)"
  printf "[$result]"
}

tmuxlineLeft() {
  _windows
}
tmuxlineMiddle() {
  printf "[middle]"
}
tmuxlineRight() {
  _disk
  _tmuxlineInfo
  _containerId
}
