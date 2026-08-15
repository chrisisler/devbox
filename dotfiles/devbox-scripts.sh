#!/usr/bin/env bash

set -eu

devbox() {
  local repo="$1"
  local workdir="$2"
  local workdirName="$(basename "$workdir")"
  local branchName="$(git rev-parse --abbrev-ref HEAD)"

  docker run --interactive --tty --rm \
    --volume "$workdir:/home/devuser/$workdirName" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh" \
    --name "devbox-$branchName" \
      ${repo:?}
}
