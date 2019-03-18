#!/usr/bin/env bash

# straight up stolen from https://github.com/Shougo/neobundle.vim/blob/master/bin/neoinstall
# The `-V1` option is included as it's a NeoVim-only option.

VIMRC=$HOME/.vimrc

nvim -N -u $VIMRC -c "try | PlugInstall! $* | finally | qall! | endtry" \
        -U NONE -i NONE -V1 -e -s
echo ''
