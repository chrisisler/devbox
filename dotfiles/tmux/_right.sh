#!/usr/bin/env bash

set -eu

_disk() {
  local avail="$(df -kHl | grep "/$" | awk '{ print $4 }')"
  printf "[$avail]"
}

_tmuxlineInfo() {
  local windows="$(tmux list-windows | wc -l | tr -d ' ')W"
  local sessions="$(tmux list-sessions | wc -l | tr -d ' ')S"
  printf "[$windows $sessions]"
}

_containerId() {
  local result="ID: "$(uname -n)""
  printf "[$result]"
}

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

tmuxlineRight() {
  _disk
  _windows
  _containerId
  _tmuxlineInfo
}

tmuxlineRight
