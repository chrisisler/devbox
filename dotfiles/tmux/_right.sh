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
  local windows="$(tmux list-windows | wc -l | xargs)"
  local format="#{window_index}"$'\t'"#{window_name}"$'\t'"#{window_active}"
  local result=""
  while IFS=$'\t' read -r index name active; do
    local label="$name"
    if [[ $windows -gt 1 ]]; then
      label="$index:$name"
    fi
    if [[ "$active" == "1" ]]; then
      label="#[fg=colour11]$label#[fg=colour7]"
    fi
    result+="$label "
  done < <(tmux list-windows -F "$format")
  printf "[%s]" "${result% }"
}

tmuxlineRight() {
  _windows
  # _disk
  # _containerId
  _tmuxlineInfo
}

tmuxlineRight
