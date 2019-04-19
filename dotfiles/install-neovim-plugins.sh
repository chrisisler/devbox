#!/usr/bin/env sh

# straight up stolen from https://github.com/Shougo/neobundle.vim/blob/master/bin/neoinstall

vimrc=$HOME/.config/nvim/init.vim

nvim -u $vimrc -U NONE -i NONE -e -s -c "try | PlugInstall! $* | finally | qall! | endtry"

echo ''
