#!/usr/bin/env bash

# straight up stolen from https://github.com/Shougo/neobundle.vim/blob/master/bin/neoinstall
# The `-V1` option is removed as it's a NeoVim-only option.

VIMRC=$HOME/.vimrc

vim -N -u $VIMRC -U NONE -i NONE -e -s

exit 0
