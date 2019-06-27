#!/usr/bin/env bash

set -eu

_disk() {
  local result="Disk"
  printf "[$result]"
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

tmuxlineRight() {
  # _disk
  _containerId
  _tmuxlineInfo
}

tmuxlineRight
