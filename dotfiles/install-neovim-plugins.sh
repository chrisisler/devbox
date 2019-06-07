#!/bin/sh

# https://github.com/Shougo/neobundle.vim/blob/master/bin/neoinstall

vimrc=$HOME/.config/nvim/init.vim

printf "\nInstalling plugins...\n"
nvim -N -u $vimrc -c "try | PlugInstall! $* | finally | qall! | endtry" -U NONE -i NONE -es

exit 0
