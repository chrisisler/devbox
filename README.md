## Devbox

Containerized development environment.

## Pre-reqs

1. [Docker](https://docs.docker.com/install/)
1. Make
1. GitHub SSH keys for devbox in `~/.ssh/devbox`

## Run

1. Clone repo
1. `make`
1. `make run`

## Next

- Autocompletion
  - Lua warning dissappears when neocomplete does
- Virtualize host filesystem
- Fish shell
- Mail CLI

## Reading

- https://www.youtube.com/watch?v=Qhg2XqwL6nY
- https://github.com/bobpace/devbox/
- https://blog.codeship.com/running-rails-development-environment-docker/
- https://medium.com/@mccode/processes-in-containers-should-not-run-as-root-2feae3f0df3b
- https://www.garron.me/en/linux/visudo-command-sudoers-file-sudo-default-editor.html
- https://github.com/nodejs/docker-node/blob/master/Dockerfile-jessie.template
- https://superuser.com/questions/605659/why-there-is-no-sudoers-file-etc-sudoers-no-such-file-or-directory
- https://stackoverflow.com/questions/2145590/what-is-the-purpose-of-phony-in-a-makefile
- https://superuser.com/questions/7414/how-can-i-search-the-bash-history-and-rerun-a-command
- https://stackoverflow.com/a/2514933
- https://superuser.com/questions/151557/what-are-build-essential-build-dep
- https://stackoverflow.com/questions/19472554/build-vim-with-lua-on-linux-mint
- https://github.com/Shougo/neocomplete.vim/issues/31#issuecomment-22956310
- https://serverfault.com/a/894545
- https://ss64.com/bash/syntax-inputrc.html
- https://tecadmin.net/install-yarn-debian/
- https://github.com/moby/moby/issues/6396#issuecomment-270550056
- https://tecadmin.net/install-latest-nodejs-npm-on-debian/
- https://elegantinfrastructure.com/containers/cotw-debian-jessie-slim/
- https://stackoverflow.com/questions/27482504/how-to-access-git-repo-with-my-private-key-from-dockerfile
- https://github.com/moby/moby/issues/6396#issuecomment-54328263
- https://github.com/moby/moby/issues/6396#issuecomment-267261192
- https://www.rust-lang.org/en-US/other-installers.html
- https://github.com/rust-lang-nursery/docker-rust/blob/master/1.30.0/stretch/slim/Dockerfile
- Apparently installing Java on Debian is `apt-get install openjdk-8-jdk-headless`
- Apparently `ln --symbolic` requires absolute paths to make any fricken sense
- `fg` and `bg` values for cterm?g require `highlight Normal` to be set first, [see here](https://github.com/neovim/neovim/pull/5319#discussion_r78295368).
- https://github.com/junegunn/vim-plug/issues/675#issuecomment-328157169
