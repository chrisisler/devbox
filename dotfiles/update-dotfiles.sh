#!/usr/bin/env bash

# Throw error if any subcommand fails.
set -e

main() {
  local here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Vim
  cp ~/.vimrc "$here"
  mkdir -p "$here/.vim"
  cp -r ~/.vim/rc "$here/.vim/"
  mkdir -p "$here/.vim/autoload"
  cp ~/.vim/autoload/plug.vim "$here/.vim/autoload/"

  # Vim plugins
  cp -R ~/.vim/plugged "$here/.vim/plugged"

  # cp ~/.inputrc "$here"

  printf "\nDone! Dotfiles updated.\n"

  # git add "$(basename "${0}")"
  # git add .
  # git commit -m "$(date "+%Y-%m-%d %H:%M")"
}

main
