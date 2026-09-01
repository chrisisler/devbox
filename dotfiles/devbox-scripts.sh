#!/usr/bin/env bash

set -eu

devbox() {
  local repo="$1"
  local branchName="$(git rev-parse --abbrev-ref HEAD)"

  docker run --interactive --tty --rm \
    --init \
    --cap-drop=ALL \
    --security-opt=no-new-privileges \
    --memory=12g \
    --cpus=6 \
    -e GH_TOKEN="$(gh auth token)" \
    -e MODEL="openai/gpt-5.6-luna" \
    -p 127.0.0.1:3000:3000 \
    -p 127.0.0.1:5173:5173 \
    -p 127.0.0.1:8082:8082 \
    --volume "$HOME/Desktop/devbox:/home/devuser/devbox" \
    --volume "$HOME/Desktop/projects/habitops:/home/devuser/habitops" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh:ro" \
    --volume "$HOME/.codex:/home/devuser/.codex" \
    --volume "$HOME/.fcc:/home/devuser/.fcc" \
    --volume "$HOME/.copilot:/home/devuser/.copilot" \
    --volume "$HOME/.local/share/opencode:/home/devuser/.local/share/opencode" \
    --name "agentbox-$branchName" \
      ${repo:?} /bin/bash
}
