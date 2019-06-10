#!/usr/bin/env bash

set -eu

# Run the image and jump into it.
devbox() {
  local repo="$1"

  docker run --interactive --tty --rm \
    --volume "$HOME/Code:/home/devuser/Code" \
    --volume "$HOME/Main:/home/devuser/Main" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh" \
    --volume "$HOME/.config/alacritty:/home/devuser/.config/alacritty" \
    --publish 3000:3000 \
    $repo
}
