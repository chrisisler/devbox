#!/usr/bin/env bash

set -eu

devbox() {
  local repo="$1"
  local workdir="$HOME/Desktop/projects/habitops"
  # local workdir="$2"
  local workdirName="$(basename "$workdir")"
  local branchName="$(git rev-parse --abbrev-ref HEAD)"
  if ! docker info --format '{{json .Runtimes}}' | grep -q '"runsc"'; then
    echo "ERROR: gVisor runsc unavailable; refusing to start" >&2
    return 1
  fi

  # runsc cannot share the host IPC namespace, so --ipc=host is dropped.
  docker run --interactive --tty --rm \
    --init \
    --runtime runsc \
    -e GH_TOKEN="$(gh auth token)" \
    -p 3000:3000 \
    -p 5173:5173 \
    --volume "$workdir:/home/devuser/$workdirName" \
    --volume "$HOME/Desktop/devbox:/home/devuser/devbox" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh:ro" \
    --volume devbox-codex:/home/devuser/.codex \
    --volume devbox-fcc:/home/devuser/.fcc \
    --volume devbox-copilot:/home/devuser/.copilot \
    --volume devbox-opencode-config:/home/devuser/.config/opencode \
    --volume devbox-opencode-data:/home/devuser/.local/share/opencode \
    --name "agentbox-$branchName" \
      ${repo:?}
}
