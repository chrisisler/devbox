#!/usr/bin/env bash
set -e

# Start tailscaled in userspace-networking mode (no TUN device needed).
if ! pgrep -x tailscaled >/dev/null 2>&1; then
  tailscaled --tun=userspace-networking --state=/var/lib/tailscale/tailscaled.state &
  # Wait for the control socket to appear.
  for i in $(seq 1 20); do
    [ -S /var/run/tailscale/tailscaled.sock ] && break
    sleep 0.25
  done
fi

exec "$@"
