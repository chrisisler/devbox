#!/usr/bin/env bash

# here="$(pwd)"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp ~/.vimrc "$here"
mkdir -p "$here/.vim"
cp -r ~/.vim/rc "$here/.vim/"

mkdir -p "$here/.vim/autoload"
cp ~/.vim/autoload/plug.vim "$here/.vim/autoload/"

# cp ~/.tmux.conf "$here"
# cp ~/.tmux/tmuxline.conf "$here"

# cp ~/.bashrc "$here"

# cp ~/.bash_profile "$here"
# cp ~/.inputrc "$here"
# cp ~/.cvimrc "$here"

# Tmux statusline scripts
# cp -r ~/Code/Status "$here"

# cp ~/.config/ranger/rc.conf "$here"
# cp ~/.config/cmus/autosave "$here"

# git add "$(basename "${0}")"
# git add .
# git commit -m "$(date "+%Y-%m-%d %H:%M")"
