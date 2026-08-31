#!/usr/bin/env bash

set -eu

devbox() {
  local repo="$1"
  local branchName="$(git rev-parse --abbrev-ref HEAD)"
  if ! docker info --format '{{json .Runtimes}}' | grep -q '"runsc"'; then
    echo "ERROR: gVisor runsc unavailable; refusing to start" >&2
    return 1
  fi

  # runsc cannot share the host IPC namespace, so --ipc=host is dropped.
  docker run --interactive --tty --rm \
    --init \
    --runtime runsc \
    --cap-drop=ALL \
    --security-opt=no-new-privileges \
    --memory=12g \
    --cpus=6 \
    -e GH_TOKEN="$(gh auth token)" \
    -p 127.0.0.1:3000:3000 \
    -p 127.0.0.1:5173:5173 \
    --volume devbox-workspace:/home/devuser/devbox \
    --volume habitops-workspace:/home/devuser/habitops \
    --volume devbox-codex:/home/devuser/.codex \
    --volume devbox-fcc:/home/devuser/.fcc \
    --volume devbox-copilot:/home/devuser/.copilot \
    --volume devbox-opencode-config:/home/devuser/.config/opencode \
    --volume devbox-opencode-data:/home/devuser/.local/share/opencode \
    --entrypoint /usr/local/bin/devbox-init \
    --name "agentbox-$branchName" \
      ${repo:?}
}
