#!/usr/bin/env bash

set -eu

devbox() {
  local repo="$1"
  local branchName="$(git rev-parse --abbrev-ref HEAD)"

  docker run --interactive --tty --rm \
    --volume "$HOME:/home/devuser/hosted-home" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh" \
    --name "devbox-$branchName" \
      ${repo:?}
}
