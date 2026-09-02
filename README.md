## Devbox

Containerized development environment for CLI agent use.

## Pre-reqs

1. [Docker](https://docs.docker.com/install/) or [Podman](https://podman.io/)
1. Make (`automake` / `cmake`)
1. An authenticated GitHub CLI session (`gh auth login`)
  - Treat this token as exposed to the agent, ensure it is scoped properly

See [security-checklist.md](security-checklist.md) for the agent-container threat model and remaining work.

## Run

1. Clone repo
1. `make && make run  # build + run the image`

Multiple `make run` processes can run at once, including multiple windows on
the same branch. Each container gets a sanitized branch-based name with a
process suffix. The first live devbox owns host ports `3000`, `5173`, and
`8082`; later devboxes automatically skip those bindings. All containers still
share the configured host worktrees, so agents must coordinate file changes.

## Security / isolation

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

## Working state (agent handoff)

- Tailscale is installed in the image but `tailscaled` was not running, so
  `tailscale up` failed with "failed to connect to local tailscaled".
- Fix: added `entrypoint.sh` that starts `tailscaled --tun=userspace-networking`
  (no TUN device / no systemd needed in a container) and waits for the control
  socket. The Dockerfile now uses it as `ENTRYPOINT`, so `CMD`/interactive bash
  still runs after the daemon is up.
- `tailscale up` still needs interactive login/auth (browser or `tailscale login`).
- Not yet built/tested: run `make && make run` to verify.

## tmux handoff (agentless-agent guidance)

tmux is the operator's remote shell surface. Sessions, window indices, window
names, and pane content are **not fixed** — they change each run. Do not hardcode
`0:1`, `session 0`, or specific window titles. Discover the live layout first,
then work generically.

### Orientation

- This interactive chat runs inside a tmux session on the local machine. Other
  windows in that session may live-SSH into a remote Linux box, run
  dashboards, tail logs, or do anything else. Which window is which varies.
- An SSH window can itself host a **nested tmux server** on the remote side,
  shown as a tab bar in the captured pane's bottom status line
  (e.g. `[0] 0:btop 1:podman ...`). The local tmux cannot query that remote
  server directly.

### Discover the live layout

```sh
tmux ls                              # sessions; ids not guaranteed (often '0')
tmux list-windows -t <session> -F '#{window_index} #{window_name} #{pane_current_path}'
tmux list-panes  -t <session>        # pane ids + current command
tmux capture-pane -t <session>:<win> -p   # read a window's visible content
```

### Drive a nested tmux (e.g. the remote SSH window)

A remote tmux is only reachable by **injecting keystrokes into the local pane**
and **reading back its captured output** — there is no direct server access.

```sh
# find the SSH pane: list windows, look for the ssh one, note its <win>
tmux send-keys -t <session>:<win> C-b n     # next window in nested tmux
sleep 1                                     # let it render
tmux capture-pane -t <session>:<win> -p     # read result; tab bar shows which nested win
```

- Cycle with `C-b n` (next), `C-b p` (prev), `C-b <digit>` (jump by index).
- Treat every injected keystroke as **live input visible on the operator's
  screen**. Space commands out with `sleep` so screens render before capture.
- When done, navigate back to the window you started on and leave the pane as
  you found it.

## Next

- Virtualize host filesystem
- Bash Line Editor
- Containerized persisted, backed-up email client TUI setup

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
