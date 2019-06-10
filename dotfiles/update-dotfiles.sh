#!/usr/bin/env bash

set -eu

# This script copies dotfiles from litebox to devbox.
main() {
  local here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Copy vim config
  mkdir -p "$here/.vim"
  cp -r ~/.vim/rc/syntax-highlighting "$here/.vim/"
  cp ~/.vim/rc/{custom-highlighting,general-settings,misc,status-line,misc}.vim "$here/.vim/rc/"

  # Copy code snippets
  mkdir -p "$here/.vim/snippets"
  cp -r ~/.vim/snippets "$here/.vim/"

  printf "Note: The following files must be updated manually:\n.vimrc\n.vim/rc/plugins.vim\n"
  printf "\nDone! Dotfiles updated.\n"
}

main
