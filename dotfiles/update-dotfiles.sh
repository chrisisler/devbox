#!/usr/bin/env bash

set -eu

# Copy dotfiles from host to devbox.
main() {
  local here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  mkdir -p "$here/.vim"
  cp -r ~/.vim/rc/syntax-highlighting "$here/.vim/rc/"
  cp ~/.vim/rc/{custom-highlighting,mappings,general-settings,misc,status-line,misc}.vim "$here/.vim/rc/"

  mkdir -p "$here/.vim/snippets"
  cp -r ~/.vim/snippets "$here/.vim/"

  printf "Note: The following files must be updated manually:\n.vimrc\n.vim/rc/plugins.vim\n.bashrc\n.inputrc\n"
  printf "\nDone! Dotfiles updated.\n"
}

main
