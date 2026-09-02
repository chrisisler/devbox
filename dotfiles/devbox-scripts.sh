#!/usr/bin/env bash

set -eu

devbox() {
  local repo="$1"
  local branchName="$(git rev-parse --abbrev-ref HEAD)"
  local containerName="devbox-${branchName//[^a-zA-Z0-9_.-]/-}-$$"
  local dockerArgs=(
    run
    --interactive
    --tty
    --rm
    --init
    --cap-drop=ALL
    --security-opt=no-new-privileges
    --memory=12g
    --cpus=6
    -e "GH_TOKEN=$(gh auth token)"
  )

  if docker ps --filter name=devbox- --format '{{.Names}}' | grep --quiet .; then
    printf 'Existing devbox detected; leaving host ports with existing container\n'
  else
    dockerArgs+=(
      -p 127.0.0.1:3000:3000
      -p 127.0.0.1:5173:5173
      -p 127.0.0.1:8082:8082
    )
  fi

  # --volume "$HOME/.fcc:/home/devuser/.fcc" \
  # -e MODEL="openai/gpt-5.6-luna" \
  docker "${dockerArgs[@]}" \
    --volume "$HOME/Desktop/devbox:/home/devuser/devbox" \
    --volume "$HOME/Desktop/projects/habitops:/home/devuser/habitops" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh:ro" \
    --volume "$HOME/.codex:/home/devuser/.codex" \
    --volume "$HOME/.copilot:/home/devuser/.copilot" \
    --volume "$HOME/.local/share/opencode:/home/devuser/.local/share/opencode" \
    --name "$containerName" \
    "${repo:?}" /bin/bash
}
