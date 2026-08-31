#!/usr/bin/env bash
#
# Register the gVisor (runsc) OCI runtime with the devbox's Docker daemon.
#
# The devbox normally runs containers on whatever Linux kernel is under Docker.
# With gVisor, the container's syscalls are intercepted by a userspace
# application kernel (runsc), so agent-executed code no longer talks to that
# kernel directly. A compromised agent must first break out of runsc.
#
# On macOS the daemon runs inside a colima (Lima) Linux VM. This script:
#   1. installs docker + colima via Homebrew (if missing)
#   2. starts the colima VM
#   3. installs runsc inside the VM from the GPG-signed gVisor apt repo
#   4. restarts Docker, verifies the runtime, and runs a smoke-test container
#
# Usage: make runtime
set -euo pipefail

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# --- host prerequisites -----------------------------------------
command -v docker >/dev/null 2>&1 || { log "docker CLI missing; installing via Homebrew"; brew install docker; }
command -v colima >/dev/null 2>&1 || { log "colima missing; installing via Homebrew"; brew install colima; }

if ! colima status >/dev/null 2>&1; then
  log "starting colima VM (4 CPU / 8 GiB)"
  colima start --cpu 4 --memory 8
fi

# --- runsc inside the VM (signed gVisor apt repo) ---------------
log "installing runsc inside the colima VM"
colima ssh -- sudo bash -s <<'EOF'
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
if ! command -v runsc >/dev/null 2>&1; then
  install -d -o root -g root -m 0755 /usr/share/keyrings
  curl -fsSL https://gvisor.dev/archive.key | gpg --dearmor --yes -o /usr/share/keyrings/gvisor-archive-keyring.gpg
  printf 'deb [arch=%s signed-by=/usr/share/keyrings/gvisor-archive-keyring.gpg] https://storage.googleapis.com/gvisor/releases release main\n' \
    "$(dpkg --print-architecture)" > /etc/apt/sources.list.d/gvisor.list
  apt-get update
  apt-get install -y runsc
fi
runsc --version
EOF

# --- restart Docker and verify -----------------------------------
log "restarting the colima Docker daemon"
colima restart

if ! docker info --format '{{json .Runtimes}}' | grep -q '"runsc"'; then
  die 'runsc is not registered with Docker. See the "gVisor (runsc)" section of the README for manual setup.'
fi
log "runsc registered:"
docker info --format '{{json .Runtimes}}' | sed 's/,/\n    /g'

log "smoke test: running a container under runsc"
docker run --rm --runtime=runsc debian:trixie-slim echo "gvisor: OK"

echo
echo "runsc is ready. From now on 'make run' launches the devbox with --runtime=runsc."
echo "Force the old runtime with: DEVOX_RUNTIME=runc make run"