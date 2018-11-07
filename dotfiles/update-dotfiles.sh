#!/usr/bin/env bash

set -eu

# This script copies dotfiles from litebox to devbox.
main() {
  local here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Vim
  cp ~/.vimrc "$here"

  # Copy vim config
  mkdir -p "$here/.vim"
  cp -r ~/.vim/rc "$here/.vim/"

  # Copy vim plugin manager
  mkdir -p "$here/.vim/autoload"
  cp ~/.vim/autoload/plug.vim "$here/.vim/autoload"

  # Copy code snippets
  mkdir -p "$here/.vim/snippets"
  cp -r ~/.vim/snippets "$here/.vim/"

  printf "\nDone! Dotfiles updated.\n"
}

main
