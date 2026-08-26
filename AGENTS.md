# Repository instructions

- Use Debian for the development container; never switch the Dockerfile OS to Ubuntu.
- Playwright Chromium is installed at `/opt/playwright` and linked at
  `/opt/google/chrome/chrome`; use `playwright-cli` directly without installing
  a browser or adding a temporary executable-path config.
