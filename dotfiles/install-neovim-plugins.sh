#!/usr/bin/env sh

# straight up stolen from https://github.com/Shougo/neobundle.vim/blob/master/bin/neoinstall

vimrc=$HOME/.config/init.vim

nvim -N -u $vimrc -c "try | PlugInstall! $* | finally | qall! | endtry" \
        -U NONE -V1 -i NONE -e -s

echo ''
