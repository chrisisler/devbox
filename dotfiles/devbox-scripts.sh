#!/usr/bin/env bash

set -eu

devbox() {
  local repo="$1"
  local workdir="$HOME/Desktop/projects/habitops"
  # local workdir="$2"
  local workdirName="$(basename "$workdir")"
  local branchName="$(git rev-parse --abbrev-ref HEAD)"

  docker run --interactive --tty --rm \
    -e GH_TOKEN="$(gh auth token)" \
    --volume "$workdir:/home/devuser/$workdirName" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh" \
    --volume "$HOME/.copilot:/home/devuser/.copilot" \
    --name "agentbox-$branchName" \
      ${repo:?}
}
