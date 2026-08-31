## Devbox

Containerized development environment for CLI agent use.

## Pre-reqs

1. [Docker](https://docs.docker.com/install/)
1. Make
1. GitHub SSH keys for devbox in `~/.ssh/devbox`
  - Only necessary for `git` commands.

## Run

1. Clone repo
1. `make && make run  # (re)build + run the image`

## Security / isolation

The LLM itself runs on a remote provider; what runs locally is the code the
agent executes. By default Docker containers share a kernel with the host/VM, so
a hostile or compromised agent has direct syscall access to that kernel.

- **Runtime (gVisor runsc).** `make runtime` installs the gVisor `runsc` OCI
  runtime into the Docker daemon that the devbox uses. `make run` then launches
  the devbox with `--runtime=runsc`, so agent syscalls are handled by gVisor's
  userspace application kernel instead of the underlying Linux kernel. It falls
  back to the default `runc` runtime (with a warning) if runsc is not
  registered, and can be forced with `DEVOX_RUNTIME=runc make run`.
- **colima VM (macOS).** Docker Desktop cannot use custom runtimes; the setup
  script instead serves the daemon from a colima (Lima) Linux VM. Containers
  therefore run inside a guest VM *and* under gVisor. On macOS the container
  kernel is never the macOS kernel: macOS is already behind Apple hardware
  virtualization (Virtualization.framework), so even plain `runc` containers do
  not share the host kernel. `--ipc=host` was dropped because runsc cannot
  share the guest VM's IPC namespace. See the "What this does and does not
  buy" section below.
- **Limits.** gVisor is an application kernel, not a microVM, so the guest VM's
  Linux kernel is reachable *through* runsc (syscalls are interpreted in
  userspace, not hardware-isolated). The remaining exposures are the ones
  containers always have by design: credentials injected into the sandbox
  (e.g. `GH_TOKEN`, `.codex`, `.copilot`) and writable volume mounts of host
  directories. Treat those as attacker-visible.

`rtk` (rtk-ai/rtk) is a token-compression CLI proxy, and `ponytail` is a
code-minimalism prompt skill; neither provides isolation.

### What this does and does not buy

- **It buys:** the macOS host kernel stays unreachable from container code.
  On Apple Silicon the container never shared it anyway — macOS is behind
  hardware virtualization — and `runsc` additionally stops agent syscalls from
  reaching even the colima Linux VM's kernel directly.
- **It does not buy:** protection from what is mounted or injected by design.
  The container can read/write whatever you bind into it — the project
  directory, this repo, `.codex`, `.copilot` — and anything whose secret is
  exported as an environment variable (e.g. `GH_TOKEN`) is available to the
  agent. A full microVM wall (Kata/Firecracker) would not change that either;
  it would only add a per-container kernel, which requires Apple M3+ (nested
  virtualization).
- **Where AIs run:** the models themselves execute on the remote provider; the
  devbox only runs the agent's shelling out (edits, builds, Playwright, CLI
  tools).

## Playwright UI feedback

Install the Playwright CLI in the devbox for headless browser feedback from a coding agent:

```sh
npm install -g @playwright/cli@latest
playwright-cli install --skills
```

Start a Vite app with `--host 0.0.0.0`, then inspect it with:

```sh
playwright-cli -s=devbox open http://127.0.0.1:5173
playwright-cli -s=devbox snapshot --filename=/tmp/devbox-ui.yml
playwright-cli -s=devbox screenshot --filename=/tmp/devbox-ui.png
```

Playwright is headless by default. If browser dependencies need to run in a separate container, use the official `mcr.microsoft.com/playwright` image with `--init --ipc=host`. Do not mount `/var/run/docker.sock` or use `--privileged` just to provide browser access.

## Next

- Virtualize host filesystem (investigate Tailscale)
- Fish shell (not needed)
- Mail CLI (configuring CLI email is... not yet attempted)
- Utilize `df -kHl` on devbox tmuxline
- `sbx` (can't get it running)
- smaller base image (alpine has musl/glibc compat issue, will try debian-slim next)

## Reading

- https://docs.docker.com/reference/cli/sbx/
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
- https://github.com/Shougo/deoplete.nvim
- https://stackoverflow.com/questions/6496778/vim-run-autocmd-on-all-filetypes-except
