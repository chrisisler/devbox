#!/usr/bin/env bash

set -eu

gh auth setup-git

for repo in devbox habitops; do
  [ -d "/home/devuser/$repo/.git" ] || gh repo clone "chrisisler/$repo" "/home/devuser/$repo"
done

exec "$@"
