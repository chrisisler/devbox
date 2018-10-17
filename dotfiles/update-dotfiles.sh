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

  # Tmux
  # cp ~/.tmux.conf "$here"
  # cp ~/.tmux/tmuxline.conf "$here"

  # cp ~/.inputrc "$here"

  # Tmux statusline scripts
  # cp -r ~/Code/Status "$here"

  printf "\nDone! Dotfiles updated.\n"
  # git add "$(basename "${0}")"
  # git add .
  # git commit -m "$(date "+%Y-%m-%d %H:%M")"
}

main
