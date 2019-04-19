#!/usr/bin/env bash

# "Inspired by" https://github.com/Shougo/neobundle.vim/blob/master/bin/neoinstall

vimrc=$HOME/.config/nvim/init.vim

printf "\nInstalling plugins...\n"
nvim -N -u $vimrc -U NONE -V1 -i NONE -e -s -c "try | PlugInstall! $* | finally | qall! | endtry"

exit 0
