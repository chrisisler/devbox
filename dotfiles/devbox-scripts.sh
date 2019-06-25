#!/usr/bin/env bash

set -eu

devbox() {
  local repo="$1"

  docker run --interactive --tty --rm \
    --volume "$HOME:/home/devuser/hosted-home" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh" \
    $repo
}
