#!/usr/bin/env bash
set -e

# Start tailscaled in userspace-networking mode (no TUN device needed).
if ! pgrep -x tailscaled >/dev/null 2>&1; then
  tailscaled --tun=userspace-networking --socket=/var/run/tailscale/tailscaled.sock --state="$HOME/.tailscale/tailscaled.state" &
  # Wait for the control socket to appear.
  for i in $(seq 1 20); do
    [ -S /var/run/tailscale/tailscaled.sock ] && break
    sleep 0.25
  done
fi

# Inject an ssh config so `ssh debiani7` works from the container; write into
# the mounted ~/.ssh (razor if the user already has a config).
# if [ ! -f "$HOME/.ssh/config" ]; then
#   cat > "$HOME/.ssh/config" <<'EOF'
# Host debiani7
#     HostName debiani7.tail8535bb.ts.net
#     User inspiron
#     IdentityFile ~/.ssh/habitops_ci_deploy_key
# EOF
#   chmod 600 "$HOME/.ssh/config"
# fi

exec "$@"
