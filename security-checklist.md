# Devbox security checklist

Threat model: a malicious or compromised agent running in the `make run` container.
Scope: lasting damage to the host OS, host files/data, credentials, and remote accounts.

## Current protections

- [x] No Docker socket mount.
- [x] No `--privileged`, host PID, host IPC, or host network flags.
- [x] No host repository, SSH key, API-key, or agent-state bind mounts.
- [x] Agent repositories and state use Docker volumes.
- [x] Docker Desktop's Linux VM keeps containers from sharing the macOS host kernel.
- [ ] Do not treat container credentials as safe: the agent can read and exfiltrate them.

## Host files and data

- [x] Use disposable volume-backed clones for devbox and habitops.
- [x] Stop mounting host `.codex`, `.fcc`, `.copilot`, and OpenCode directories.
- [x] Keep the host-side launcher outside the agent workspace.
- [ ] Verify container root cannot write outside the intended project mount.

## Credentials and remote data

- [ ] Remove `GH_TOKEN` from the container; use a short-lived, least-privilege token if needed.
- [x] Do not mount a host SSH private key.
- [x] Do not mount the OpenAI API key.
- [ ] Prevent agents from reading OpenAI/Codex authentication state.
- [ ] Rotate credentials that have already been exposed to the container.
- [ ] Define and test the maximum damage allowed to GitHub, Vercel, Okta, and other remote accounts.

## Container boundary

- [ ] Run rootless or with user namespaces.
- [ ] Remove passwordless `sudo` from the image. ([PR #7](https://github.com/chrisisler/devbox/pull/7))
- [x] Drop capabilities and enable `no-new-privileges`.
- [ ] Use a read-only container filesystem with explicit temporary filesystems.
- [x] Limit container memory to 12 GB and CPUs to 6.
- [ ] Add a portable per-container storage limit; Docker Desktop support varies.
- [ ] Add a PID limit.
- [x] Bind published ports to localhost only.
- [x] Keep Docker/Podman sockets, host devices, and host namespaces unavailable.

## Build and supply chain

- [ ] Pin selected stable build inputs. ([PR #8](https://github.com/chrisisler/devbox/pull/8))
- [ ] Add a minimal `.dockerignore`. ([PR #8](https://github.com/chrisisler/devbox/pull/8))
- [x] Never pass secrets into Docker builds or write them into image layers.
- [ ] Review Dockerfile changes before rebuilding images used by agents.

## Accepted risks

- [x] Keep NodeSource's `curl | bash` installer.
- [x] Allow mutable Debian/Node.js/Terraform apt packages.
- [x] Allow npm transitive dependency resolution.
- [x] Clone the latest devbox `master`; pin only Okta CLI.
- [x] Let the pinned Playwright package select its matching Chromium revision.

## Validation

- [ ] Inspect the final container mounts, user, capabilities, runtime, ports, and resource limits.
- [ ] Run a canary test proving the agent cannot modify a protected host file or config directory.
- [ ] Run a credential test proving no token, key, or API secret is readable in the container.
- [ ] Re-run this checklist after changing mounts, runtimes, images, or agent tools.
