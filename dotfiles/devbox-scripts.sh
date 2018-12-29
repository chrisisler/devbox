#!/bin/bash

set -eu

# Run the image and jump into it.
devbox() {
  # local REPOSITORY="$1"
  local REPOSITORY="chrisisler/devbox"

  docker run --interactive --tty --rm \
    --volume "${HOME}/Code:/home/devuser/Code" \
    --volume "${HOME}/Main:/home/devuser/Main" \
    --volume "${HOME}/.ssh/devbox:/home/devuser/.ssh" \
    ${REPOSITORY}
}

cleanUnusedImages() {
  docker rmi "$(docker images --quiet --filter "dangling=true")"
}
