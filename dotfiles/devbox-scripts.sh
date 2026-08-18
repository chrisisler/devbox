#!/usr/bin/env bash

set -eu

devbox() {
  local repo="$1"
  local workdir="$2"
  local workdirName="$(basename "$workdir")"
  local branchName="$(git rev-parse --abbrev-ref HEAD)"

  sbx run --interactive --tty --rm \
    -e GH_TOKEN="$(gh auth token)" \
    --mount "$workdir:/home/agentuser/$workdirName" \
    --mount "$HOME/.ssh/devbox:/home/agentuser/.ssh" \
    --mount "$HOME/.copilot:/home/agentuser/.copilot" \
    --name "devbox-$branchName" 
    "${repo:?}"
}
