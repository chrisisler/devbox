#!/usr/bin/env bash

set -eu

# Run the image and jump into it.
devbox() {
  local repo="$1"

  docker run --interactive --tty --rm \
    --volume "$HOME/Code:/home/devuser/Code" \
    --volume "$HOME/Main:/home/devuser/Main" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh" \
    $repo
}

cleanUnusedImages() {
  # docker rmi "$(docker images --quiet --filter "dangling=true")"
  docker images --quiet --filter "dangling=true" | xargs docker rmi
}
