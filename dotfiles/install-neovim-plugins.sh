#!/bin/sh

# "Inspired by" https://github.com/Shougo/neobundle.vim/blob/master/bin/neoinstall

vimrc=$HOME/.config/nvim/init.vim

printf "\nInstalling plugins...\n"
vim -N -u $vimrc -U NONE -V2 -i NONE -e -s -c "try | PlugInstall! | finally | qall! | endtry"

exit 0
