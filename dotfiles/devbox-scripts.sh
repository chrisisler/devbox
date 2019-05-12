#!/usr/bin/env bash

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
  # docker rmi "$(docker images --quiet --filter "dangling=true")"
  docker images --quiet --filter "dangling=true" | xargs docker rmi
}

update() {
  local here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  cp ~/.vimrc "$here"
  mkdir -p "$here/.vim"
  cp -r ~/.vim/rc "$here/.vim/"

  mkdir -p "$here/.vim/snippets"
  cp -r ~/.vim/snippets "$here/.vim/"

  printf "\nDotfiles updated.\n"
}
