#!/usr/bin/env bash

# Detect .vimrc path.
VIMRC=$HOME/.vimrc


vim -N -u $VIMRC -c "try | PlugInstall! $* | finally | qall! | endtry" \
        -U NONE -i NONE -e -s
        # -U NONE -i NONE -V1 -e -s
echo ''
