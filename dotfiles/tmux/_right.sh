#!/usr/bin/env bash

set -eu

_disk() {
  local avail="$(df -kHl | grep "/$" | awk '{ print $4 }')"
  printf "[$avail]"
}

_containerId() {
  local result="ID: "$(uname -n)""
  printf "[$result]"
}

_paneProcess() {
  local pid="$1"
  local child=""
  local command=""

  while :; do
    child="$(pgrep -P "$pid" | head -n 1 || true)"
    [[ -z "$child" ]] && break
    pid="$child"
  done

  command="$(ps -o args= -p "$pid" | sed -e 's/^[[:space:]]*//' || true)"
  if [[ -n "$command" ]]; then
    printf "%s" "${command%% *}" | sed -e 's#^.*/##'
  fi
}

_paneBranch() {
  local branch="$(git -C "$1" branch --show-current 2>/dev/null || true)"
  printf "%s" "$branch"
}

_windows() {
  local format="#{window_id}"$'\t'"#{window_index}"$'\t'"#{window_name}"$'\t'"#{window_active}"
  local result=""
  while IFS=$'\t' read -r windowId index name active; do
    local panes=""
    while IFS=$'\t' read -r paneIndex paneActive panePid panePath; do
      local paneProcess="$(_paneProcess "$panePid")"
      local paneBranch="$(_paneBranch "$panePath")"
      panePath="${panePath/#$HOME\//~\/}"
      panePath="${panePath/#\/home\/devuser\//~\/}"
      [[ -z "$paneProcess" ]] && paneProcess="$name"
      local paneLabel="$index:$paneProcess:$panePath"
      [[ -n "$paneBranch" ]] && paneLabel+=":$paneBranch"
      if [[ "$active" == "1" && "$paneActive" == "1" ]]; then
        paneLabel="#[fg=colour11]$paneLabel#[fg=colour7]"
      else
        paneLabel="#[fg=colour7]$paneLabel#[fg=colour7]"
      fi
      panes+="$paneLabel "
    done < <(tmux list-panes -t "$windowId" -F "#{pane_index}"$'\t'"#{pane_active}"$'\t'"#{pane_pid}"$'\t'"#{pane_current_path}")
    result+="${panes% } "
  done < <(tmux list-windows -F "$format")
  printf "[%s]" "${result% }"
}

tmuxlineRight() {
  _windows
  # _disk
  # _containerId
}

tmuxlineRight
