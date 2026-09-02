# Debian Trixie Host Template (Ansible)

Portable, "ponytail-style" Ansible host template. Rebuild a wipeable Debian
Trixie Slim VPS from scratch. Reconstructs the *intended* host config of the
source host (Debian 13.6, hostname `debiani7`) — not a snapshot of transient
runtime state. Nothing here is executed against the live source host.

Validated statically: playbook syntax-check passes, every var resolves
(only `tailscale_authkey` is external-by-design, gated by `is defined`),
sshd drop-in template renders sshd-valid output, tasks idempotent. Not
destructively tested on any real host.

## Layout

```
ansible.cfg                  ansible defaults
inventory.ini.example        inventory template (copy to inventory.ini)
group_vars/all.yml           all machine-specific + policy values (no secrets)
playbook.yml                 idempotent host bootstrap, ordered
requirements.yml             collections used
templates/sshd-hardening.conf.j2   sshd lock-down drop-in
README.md                    this file
```

## Usage

1. Copy inventory (local/root, replace target host):
   ```
   cp inventory.ini.example inventory.ini
   ```
   For a remote VPS: `ansible_connection=ssh`, set `ansible_host` to the new
   machine (initial install must already allow key auth for your bootstrap
   user — see Secrets below).

2. Install collections:
   ```
   ansible-galaxy collection install -r requirements.yml
   ```

3. Run (dry-run first):
   ```
   ansible-playbook playbook.yml --check --diff
   ansible-playbook playbook.yml
   ```

4. Optional Tailscale (needs secret auth key, never stored in repo):
   ```
   ansible-playbook playbook.yml -e tailscale_enable=true \
       -e tailscale_authkey=tskey-auth-...
   ```

Override any `group_vars/all.yml` value per target via
`host_vars/<host>.yml`, `--extra-vars`, or group/host inventory entries.

## Secrets / credentials — NEVER in this repo

- Authorized SSH keys committed here are PUBLIC keys only.
- Tailscale auth key, any passwords, ngrok/app tokens are supplied at run
  time (`--extra-vars` or Ansible Vault). `.gitignore` blocks `.env`, vault
  password, and `inventory.ini`.
- The source host's **private** key (`/home/inspiron/.ssh/id_ed25519`),
  host SSH keys, `.bash_history`, and Tailscale node state are runtime/machine
  data and are intentionally NOT reproduced. A fresh install regenerates host
  keys and gets its own tailnet identity.

## What this reproduces (vs source host audit)

- Debian 13 trixie repos (deb.debian.org main/contrib/non-free-firmware +
  security) + Tailscale repo
- Deliberate tooling: tailscale, podman-docker (rootless), fail2ban, ufw,
  nftables, unattended-upgrades, + CLI/tool utilities
- Hardened sshd (root login off, password auth off, MaxAuthTries, AllowUsers),
  sole primary admin user in sudo group, authorized_keys
- ufw default deny-incoming / allow-outgoing with **explicit SSH allow**
- fail2ban sshd jail, unattended-upgrades (default), timezone America/Chicago
- podman rootless platform: `podman.socket` (Docker-compatible, socket-activated)
  + user lingering; app deploys wire their own user units
- Optional Tailscale (daemon present, join needs authkey) + tmux shell config

## Deliberately NOT in the host template

- The `habitops` application and its compose stack (compose.yaml,
  compose.ngrok.yaml, `.env`, `.ngrok.env`, ngrok.yml, images) — this is
  application layer with its own secrets, deployed separately on top of the
  podman platform.
- Laptop-specific firmware (intel-microcode, firmware-iwlwifi/realtek/
  intel-graphics) — omitted for VPS targets.
- Timeshift snapshots, `habitops.tar.bz2.bakup`, `.bash_history`, btop/lnav/
  ngrok runtime dirs — transient/runtime state.
- UUIDs, machine-id, host SSH keys — a fresh install regenerates these.

## Known gaps / cannot-cleanly-reproduce

- Tailscale needs a fresh auth key at first boot (no key in repo).
- Wordmark: source `/etc/hosts` / LAN DHCP lease (192.168.4.33, tailnet
  100.75.6.108) are site-specific; parameterize `host_hostname` and leave
  networking (ifupdown DHCP) stock for the VPS provider.
- Source sshd edits live in the main `sshd_config`; this template applies the
  same directives via a `sshd_config.d` drop-in (`60-hardening.conf`), which is
  cleaner, idempotent, and package-upgrade-safe.

## Design: boring by default (ponytail)

Only the deltas a fresh Trixie Slim image does not already provide are touched:
repos, packages, the admin user, sshd hardening, firewall, security tooling,
container socket, optional tailscale. Not reproduced: the hand-assembled
`debian.sources` (image ships `main contrib non-free-firmware`), locale, an
OS-version gate, and any dbus/user-scope wiring (podman uses plain socket
activation). Keep the smallest thing that works; easy to run, debug, replace.
