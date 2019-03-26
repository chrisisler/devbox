#!/usr/bin/env bash

set -eu

# Run the image and jump into it.
devbox() {
  # local REPOSITORY="$1"
  local REPOSITORY="chrisisler/devbox"

  docker run --interactive --tty --rm \
    --volume "$HOME/Code:/home/devuser/Code" \
    --volume "$HOME/Main:/home/devuser/Main:ro" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh:ro" \
    $REPOSITORY
}

cleanUnusedImages() {
  # docker rmi "$(docker images --quiet --filter "dangling=true")"
  docker images --quiet --filter "dangling=true" | xargs docker rmi
}
