#!/usr/bin/env bash

set -eu

devbox() {
  local repo="$1"
  local workdir="$HOME/Desktop/projects/habitops"
  # local workdir="$2"
  local workdirName="$(basename "$workdir")"
  local branchName="$(git rev-parse --abbrev-ref HEAD)"

  docker run --interactive --tty --rm \
    --init \
    --ipc=host \
    -e GH_TOKEN="$(gh auth token)" \
    -p 3000:3000 \
    -p 5173:5173 \
    --volume habitops-go-mod:/home/devuser/go/pkg/mod \
    --volume habitops-go-build:/home/devuser/.cache/go-build \
    --volume "$workdir:/home/devuser/$workdirName" \
    --volume "$HOME/Desktop/devbox:/home/devuser/devbox" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh:ro" \
    --volume "$HOME/.codex:/home/devuser/.codex" \
    --volume "$HOME/.copilot:/home/devuser/.copilot" \
    --name "agentbox-$branchName" \
      ${repo:?}
}
