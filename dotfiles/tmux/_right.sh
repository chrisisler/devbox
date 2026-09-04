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

_paneGitState() {
  local branch="$(git -C "$1" branch --show-current 2>/dev/null || true)"
  local changes="$(git -C "$1" status --porcelain 2>/dev/null | wc -l | tr -d ' ' || true)"
  printf "%s|%s" "$branch" "$changes"
}

_spinner() {
  local -a frames=("|" "/" "-" "\\")
  printf "%s" "${frames[$(( $(date +%s) % ${#frames[@]} ))]}"
}

_paneBusy() {
  local pid=""
  local state=""
  local -a pending=()

  while read -r child; do
    [[ -n "$child" ]] && pending+=("$child")
  done < <(pgrep -P "$1" || true)

  while [[ ${#pending[@]} -gt 0 ]]; do
    pid="${pending[0]}"
    pending=("${pending[@]:1}")
    state="$(ps -o stat= -p "$pid" | sed -e 's/^[[:space:]]*//' || true)"
    if [[ "$state" == R* || "$state" == D* ]]; then
      return 0
    fi
    while read -r child; do
      [[ -n "$child" ]] && pending+=("$child")
    done < <(pgrep -P "$pid" || true)
  done
  return 1
}

_paneActiveRecently() {
  local panePid="$1"
  local now="$(date +%s)"
  local cache="/tmp/devbox-tmux-activity-$panePid"
  local last=""

  if _paneBusy "$panePid"; then
    printf "%s" "$now" > "$cache" || true
    return 0
  fi
  [[ -r "$cache" ]] && read -r last < "$cache"
  [[ "$last" =~ ^[0-9]+$ ]] && (( now - last <= 2 ))
}

_renderWindow() {
  local windowId="$1"
  local index="$2"
  local name="$3"
  local active="$4"
  local panes=""
  while IFS=$'\t' read -r paneIndex paneActive panePid panePath; do
    local paneProcess="$(_paneProcess "$panePid")"
    local paneGitState="$(_paneGitState "$panePath")"
    local paneBranch="${paneGitState%%|*}"
    local paneChanges="${paneGitState#*|}"
    [[ -z "$paneProcess" ]] && paneProcess="$name"
    local paneLabel="$index:$paneProcess"
    [[ -n "$paneBranch" ]] && paneLabel+=":$paneBranch"
    if _paneActiveRecently "$panePid"; then
      anyBusy=1
      paneLabel="$(_spinner)$paneLabel"
    fi
    if [[ "$active" == "1" && "$paneActive" == "1" ]]; then
      paneLabel="#[fg=colour14]$paneLabel#[fg=colour7]"
    else
      paneLabel="#[fg=colour7]$paneLabel#[fg=colour7]"
    fi
    panes+="$paneLabel "
  done < <(tmux list-panes -t "$windowId" -F "#{pane_index}"$'\t'"#{pane_active}"$'\t'"#{pane_pid}"$'\t'"#{pane_current_path}")
  local windowOutput="${panes% }"
  if [[ "$active" == "1" ]]; then
    windowOutput="#[bg=colour8]$windowOutput#[bg=colour0]"
  fi
  result+="$windowOutput  "
}

_windows() {
  local target="${1:-}"
  local format="#{window_id}"$'\t'"#{window_index}"$'\t'"#{window_name}"$'\t'"#{window_active}"
  local result=""
  local anyBusy=0
  if [[ -n "$target" ]]; then
    local metadata="$(tmux display-message -p -t "$target" "$format")"
    IFS=$'\t' read -r windowId index name active <<< "$metadata"
    _renderWindow "$windowId" "$index" "$name" "$active"
  else
    while IFS=$'\t' read -r windowId index name active; do
      _renderWindow "$windowId" "$index" "$name" "$active"
    done < <(tmux list-windows -F "$format")
  fi
  [[ "$anyBusy" == "1" ]] && tmux set-option -g status-interval 1 ||
    tmux set-option -g status-interval 3
  printf "%s" "${result% }"
}

_sessions() {
  local sessionNames=""
  local sessionName=""
  local sessionCount=0
  local activeSession="$(tmux display-message -p '#{session_name}' 2>/dev/null || true)"
  local sessionLabel=""

  while IFS= read -r sessionName; do
    [[ -n "$sessionName" ]] || continue
    ((sessionCount += 1))
    sessionLabel="S$sessionName"
    if [[ "$sessionName" == "$activeSession" ]]; then
      sessionLabel="#[fg=colour14]$sessionLabel#[fg=colour7]"
    fi
    sessionNames+="${sessionNames:+ }$sessionLabel"
  done < <(tmux list-sessions -F "#{session_name}" 2>/dev/null || true)
  if ((sessionCount > 1)); then
    printf "[%s]" "$sessionNames"
  fi
}

tmuxlineRight() {
  _windows "${1:-}"
  # _disk
  # _containerId
}

if [[ "${1:-}" == "sessions" ]]; then
  _sessions
else
  tmuxlineRight "${1:-}"
fi
