# Trixie is current stable; this stage keeps the Java toolchain out of the app image.
FROM chrisisler/devbox-base-sys AS okta-builder

RUN apt-get update && \
    apt-get install --assume-yes --quiet --no-install-recommends \
    maven zlib1g-dev

# Okta CLI's native-image Maven plugin requires a GraalVM JDK.
ARG GRAALVM_VERSION=22.3.3
ARG TARGETARCH
RUN set -eux; \
    arch="${TARGETARCH}"; \
    if [ -z "${arch}" ]; then arch="$(dpkg --print-architecture)"; fi; \
    case "${arch}" in \
      amd64) graalvm_arch=amd64 ;; \
      arm64) graalvm_arch=aarch64 ;; \
      *) echo "Unsupported architecture: ${arch}" >&2; exit 1 ;; \
    esac; \
    base_url="https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAALVM_VERSION}"; \
    graalvm_archive="graalvm-ce-java17-linux-${graalvm_arch}-${GRAALVM_VERSION}.tar.gz"; \
    native_image_component="native-image-installable-svm-java17-linux-${graalvm_arch}-${GRAALVM_VERSION}.jar"; \
    for artifact in "${graalvm_archive}" "${native_image_component}"; do \
      curl --fail --silent --show-error --location \
        "${base_url}/${artifact}" --output "/tmp/${artifact}"; \
      curl --fail --silent --show-error --location \
        "${base_url}/${artifact}.sha256" --output "/tmp/${artifact}.sha256"; \
      expected="$(tr -d '[:space:]' < "/tmp/${artifact}.sha256")"; \
      actual="$(sha256sum "/tmp/${artifact}" | cut -d ' ' -f 1)"; \
      test "${actual}" = "${expected}"; \
    done; \
    mkdir --parents /opt/graalvm; \
    tar --extract --gzip --file "/tmp/${graalvm_archive}" \
      --strip-components=1 --directory /opt/graalvm; \
    /opt/graalvm/bin/gu -L install "/tmp/${native_image_component}"; \
    test -x /opt/graalvm/lib/svm/bin/native-image; \
    rm --force \
      "/tmp/${graalvm_archive}" "/tmp/${graalvm_archive}.sha256" \
      "/tmp/${native_image_component}" "/tmp/${native_image_component}.sha256"

ENV GRAALVM_HOME=/opt/graalvm
ENV JAVA_HOME=/opt/graalvm
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN java --version && \
    native-image --version && \
    mvn --version

USER devuser
ENV USER=devuser
ENV HOME=/home/devuser

RUN git clone https://github.com/okta/okta-cli.git /home/devuser/okta-cli && \
    git -C /home/devuser/okta-cli checkout --detach 08e945fce540506fc783380606ca1ab7650e2c0e && \
    cd /home/devuser/okta-cli && \
    mvn clean install -DskipTests

FROM chrisisler/devbox-base-sys

RUN curl -sSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install --assume-yes --quiet --no-install-recommends nodejs lsof postgresql && \
    npm install --global typescript@7.0.2 && \
    node --version

RUN npm install --global @openai/codex@0.151.0 @github/copilot@1.0.82

RUN curl --fail --silent --show-error \
    --location https://raw.githubusercontent.com/rtk-ai/rtk/v0.46.0/install.sh \
    --output /tmp/rtk-install.sh && \
    RTK_INSTALL_DIR=/usr/local/bin RTK_VERSION=v0.46.0 \
    sh /tmp/rtk-install.sh && \
    rm --force /tmp/rtk-install.sh && \
    rtk init -g --codex --copilot --opencode

# ENV PLAYWRIGHT_BROWSERS_PATH=/opt/playwright
# RUN npm install --global @playwright/cli@0.1.18 && \
#     mkdir --parents "${PLAYWRIGHT_BROWSERS_PATH}" && \
#     npx --yes playwright install --with-deps chromium && \
#     chmod --recursive a+rX "${PLAYWRIGHT_BROWSERS_PATH}" && \
#     playwright-cli --version
#
# RUN mkdir --parents /opt/google/chrome
# RUN ln --symbolic "$(find "${PLAYWRIGHT_BROWSERS_PATH}" -path '*/chrome-linux/chrome' -type f -print -quit)" /opt/google/chrome/chrome

RUN set -eux; \
    curl --fail --silent --show-error --location https://apt.releases.hashicorp.com/gpg | \
      gpg --dearmor --yes --output /usr/share/keyrings/hashicorp-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" \
      > /etc/apt/sources.list.d/hashicorp.list; \
    apt-get update; \
    apt-get install --assume-yes --quiet --no-install-recommends terraform; \
    terraform version

RUN npm install --global vercel
RUN apt-get install --assume-yes --quiet --no-install-recommends podman-docker nnn chromium
# Debian Chromium covers Linux ARM64, where Chrome for Testing has no release.
RUN npm install --global --allow-scripts=agent-browser agent-browser@0.35.2

# Sys: Be non-root user - Warning: affects remaining docker commands.
USER devuser
ENV USER=devuser
ENV HOME=/home/devuser

ENV PATH="${HOME}/.local/bin:${PATH}"
ENV EDITOR=/usr/bin/vi

# Free Claude Code and its provider-backed coding-agent wrappers.
RUN curl --fail --silent --show-error --location \
    https://raw.githubusercontent.com/Alishahryar1/free-claude-code/main/scripts/install.sh \
    --output /tmp/free-claude-code-install.sh && \
    sed --in-place \
      -e 's/install_claude=1/install_claude=0/g' \
      -e 's/install_cline=1/install_cline=0/g' \
      -e 's/install_codex=1/install_codex=1/g' \
      -e 's/install_dsh=1/install_dsh=0/g' \
      -e 's/install_aider=1/install_aider=0/g' \
      -e 's/install_grok=1/install_grok=0/g' \
      -e 's/install_hermes=1/install_hermes=0/g' \
      -e 's/install_muse=1/install_muse=0/g' \
      -e 's/install_opencode=1/install_opencode=1/g' \
      -e 's/install_pi=1/install_pi=0/g' \
      /tmp/free-claude-code-install.sh && \
    sh /tmp/free-claude-code-install.sh --rtk && \
    rm --force /tmp/free-claude-code-install.sh
# App:
WORKDIR /home/devuser/habitops

RUN mkdir /home/devuser/.ssh && ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# RUN playwright-cli install --skills --global

COPY --from=okta-builder /home/devuser/okta-cli/cli/target/okta /usr/local/bin/okta

# RUN go install "github.com/pressly/goose/v3/cmd/goose@v3.27.3"
RUN go install "github.com/sqlc-dev/sqlc/cmd/sqlc@v1.31.1"

CMD ["/bin/bash"]
