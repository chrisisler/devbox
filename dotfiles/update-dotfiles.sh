#!/usr/bin/env bash

set -eu

# This script copies dotfiles from litebox to devbox.
main() {
  local here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Copy vim config
  mkdir -p "$here/.vim"
  cp -r ~/.vim/rc "$here/.vim/"

  # Copy vim plugin manager
  mkdir -p "$here/.vim/autoload"

  # Copy code snippets
  mkdir -p "$here/.vim/snippets"
  cp -r ~/.vim/snippets "$here/.vim/"

  printf "Note: .vimrc must be updated manually."
  printf "\nDone! Dotfiles updated.\n"
}

main
