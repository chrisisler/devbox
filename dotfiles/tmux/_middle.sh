#!/usr/bin/env bash

set -eu

tmuxlineMiddle() {
  ~/devbox/dotfiles/tmux/_right.sh "${1:-}"
}
tmuxlineMiddle "$@"
