#!/usr/bin/env bash

set -eu

devbox() {
  local repo="$1"
  local workdir="$HOME/Desktop/projects/habitops"
  # local workdir="$2"
  local workdirName="$(basename "$workdir")"
  local branchName="$(git rev-parse --abbrev-ref HEAD)"
  local runtime="${DEVOX_RUNTIME:-runsc}"

  if ! docker info --format '{{json .Runtimes}}' | grep -q "\"${runtime}\""; then
    echo "WARNING: ${runtime} runtime unavailable (install with 'make runtime'); falling back to runc" >&2
    runtime=runc
  fi

  # runsc cannot share the host IPC namespace, so --ipc=host is dropped.
  docker run --interactive --tty --rm \
    --init \
    --runtime "${runtime}" \
    -e GH_TOKEN="$(gh auth token)" \
    -p 3000:3000 \
    -p 5173:5173 \
    --volume "$workdir:/home/devuser/$workdirName" \
    --volume "$HOME/Desktop/devbox:/home/devuser/devbox" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh:ro" \
    --volume "$HOME/.codex:/home/devuser/.codex" \
    --volume "$HOME/.copilot:/home/devuser/.copilot" \
    --name "agentbox-$branchName" \
      ${repo:?}
}
