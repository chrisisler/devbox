## Devbox

Containerized development environment for CLI agent use.

## Pre-reqs

1. [Docker](https://docs.docker.com/install/)
1. Make
1. An authenticated GitHub CLI (`gh auth login`)

See [security-checklist.md](security-checklist.md) for the agent-container threat model and remaining work.

## Run

1. Clone repo
1. `make && make run  # (re)build + run the image`

## Security / isolation

On macOS, Docker Desktop runs Linux containers inside its Linux VM. `make run`
uses Docker's default OCI runtime (normally `runc`); no Colima or custom runtime
setup is required. This removes direct macOS-kernel sharing, but it does not add
a userspace syscall boundary inside the Docker Desktop VM.

The container runtime does not protect writable volumes, persisted agent state,
or injected credentials; treat them as exposed to the agent. Repositories use
disposable Docker volumes instead of host bind mounts. Capabilities are dropped,
privilege escalation is disabled, host IPC is not shared, ports bind only to
localhost, and runs are limited to 12 GB memory and 6 CPUs. Disk use is governed
by Docker Desktop because per-container storage limits are not portable enough
for this macOS setup.

## Agent workflow

Staff-level goal: improve the workflow graph, not the tool count.

```text
Ponytail -> minimal implementation decisions
RTK -> compact shell output
AXI tools -> fewer retries and tool calls
specops -> persistent desired state and work DAG
gh/reactive/supabase adapters -> domain-specific execution
```

Use Ponytail's full ladder for implementation work: reuse first, then the
standard library or native platform features, then the smallest correct diff.
Do not simplify away tenant isolation, Okta validation, migration safety, error
handling, accessibility, or required tests.

The AXI catalog is community-maintained. Trial tools on demand first; if one
becomes part of the workflow, install it project-locally, pin its version, and
review its hooks and credential access before adding it to the image.

| Priority | Tool | Fit | Recommendation |
| --- | --- | --- | --- |
| Now | [gh-axi](https://github.com/kunchenguid/gh-axi) | HabitOps already prefers it for GitHub, PRs, CI, and version-control work. | Make it the default GitHub interface. |
| Now | [specops](https://github.com/JarvusInnovations/specops) | Adds persistent specs, plans, drift checks, and a work DAG for HabitOps. | Install only in HabitOps; let it own the spec and plan state. |
| Now | [reactive-axi](https://github.com/adeeshsharma/reactive-axi) | HabitOps is Vue/Vite; clicks in the live app can become source-oriented feedback. | Use alongside Playwright: Reactive Editor for locating UI issues, Playwright for behavior and screenshots. |
| Now | [supabase-axi](https://github.com/laizhenyoong/supabase-axi) | Matches HabitOps's Supabase PostgreSQL, RLS, migrations, and tenant authorization. | Start with non-production schema, RLS, index, and log audits. Keep writes explicit. |
| Soon | [quota-axi](https://github.com/kunchenguid/quota-axi) | The image carries Codex, Copilot, OpenCode, and other agent state. | Use as a preflight before expensive work; report quota, do not silently route providers. |
| Later | [cyber-mux](https://github.com/cyberuni/cyber-mux) | Controls tmux panes and worktrees for parallel agents. | Defer until parallel agent execution is an explicit workflow. |
| Later | [lavish-axi](https://github.com/kunchenguid/lavish-axi) | Supports interactive review of generated HTML plans, diagrams, and reports. | Add on demand for visual planning and human feedback. |
| Defer | [superbee](https://github.com/Holaxis-ai/superbee) | Durable shared agent knowledge, but explicitly early and pre-1.0. | Do not combine with `specops` until shared knowledge is a demonstrated bottleneck. |
| Defer | [jj-axi](https://github.com/aivv73/jj-axi) | Deterministic Jujutsu history editing, while these repositories use Git. | Do not add a second VCS model without a concrete need. |
| Conditional | `npm-axi`, `pg-axi`, [axi-axi](https://github.com/CodyEngel/axi-axi) | Package inspection, raw PostgreSQL operations, and authoring our own AXIs. | Use only when the matching workflow justifies them. |

Do not use `docker-axi` inside this devbox. The environment deliberately uses
Docker's default runtime, dropped capabilities, localhost-only ports, no Docker
socket, and rootless Podman for HabitOps deployment. Docker-oriented tooling
must not become a reason to add `--privileged`, a socket mount, or expose
non-local ports.

Two useful local AXIs are not currently in the community catalog:

- `podman-axi`: a small, read-only-first wrapper for the rootless Podman
  workflows on the Tierhive VPS. It could expose discovery, health, logs, and
  dry-run plans without adding a Docker compatibility layer.
- `okta-axi`: a small wrapper for the bundled `okta-cli`, focused on
  non-interactive discovery, validation, and safe configuration workflows.

Use `axi-axi` to scaffold and validate either wrapper. Keep mutations behind
explicit execution flags, redact credentials, and do not add either tool to
the image until its interface proves useful.

## Browser UI feedback

The image includes pinned `agent-browser` and Debian Chromium for headless
browser feedback. Use `agent-browser` directly.

Start a Vite app with `--host 0.0.0.0`, then inspect it with:

```sh
agent-browser open http://127.0.0.1:5173
agent-browser snapshot
agent-browser screenshot /tmp/devbox-ui.png
```

`agent-browser` is headless by default and discovers `/usr/bin/chromium`.
If browser dependencies need to run in a separate container, do not mount
`/var/run/docker.sock` or use `--privileged` just to provide browser access.

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
