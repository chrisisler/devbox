# Repository instructions

- Use Debian for the development container; never switch the Dockerfile OS to Ubuntu.
- Playwright Chromium is installed at `/opt/playwright` and linked at
  `/opt/google/chrome/chrome`; use `playwright-cli` directly without installing
  a browser or adding a temporary executable-path config.
- Target macOS with Colima and require gVisor `runsc`; never fall back to `runc`.
- Preserve dropped capabilities, `no-new-privileges`, localhost-only ports, and
  the 12 GB memory/6 CPU limits.
- Do not add a per-container storage limit; Docker Desktop/Colima support varies.
- Treat container credentials and persisted agent state as readable by agents.
