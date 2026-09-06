# syntax=docker/dockerfile:1

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

RUN --mount=type=cache,target=/home/devuser/.m2,uid=1000,gid=1000 \
    git init --quiet /home/devuser/okta-cli && \
    git -C /home/devuser/okta-cli remote add origin https://github.com/okta/okta-cli.git && \
    git -C /home/devuser/okta-cli fetch --quiet --depth 1 origin "08e945fce540506fc783380606ca1ab7650e2c0e" && \
    git -C /home/devuser/okta-cli checkout --quiet --detach FETCH_HEAD && \
    cd /home/devuser/okta-cli && \
    mvn clean install -DskipTests

FROM chrisisler/devbox-base-sys
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"

USER root
RUN apt-get update && apt-get install --assume-yes --quiet --no-install-recommends \
    podman-docker postgresql gh && \
    rm -rf /var/lib/apt/lists
RUN --mount=type=cache,target=/root/.npm \
    curl -sSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install --assume-yes --quiet --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists && \
    npm install --global typescript@7.0.2 && \
    node --version
RUN --mount=type=cache,target=/root/.npm \
    npm install --global vercel
RUN set -eux; \
    curl --fail --silent --show-error --location https://apt.releases.hashicorp.com/gpg | \
      gpg --dearmor --yes --output /usr/share/keyrings/hashicorp-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" \
      > /etc/apt/sources.list.d/hashicorp.list; \
    apt-get update; \
    apt-get install --assume-yes --quiet --no-install-recommends terraform; \
    terraform version && \
    rm -rf /var/lib/apt/lists
RUN curl -fsSL https://tailscale.com/install.sh | sh
RUN mkdir -p /var/run/tailscale && chown devuser:devuser /var/run/tailscale
RUN --mount=type=cache,target=/root/.npm \
    npm install --global @openai/codex@0.151.0 @github/copilot@1.0.82 opencode-ai
RUN --mount=type=cache,target=/root/.npm \
    npm install --global --allow-scripts=agent-browser agent-browser@0.35.2
RUN curl --fail --silent --show-error \
    --location https://raw.githubusercontent.com/rtk-ai/rtk/v0.46.0/install.sh \
    --output /tmp/rtk-install.sh && \
    RTK_INSTALL_DIR=/usr/local/bin RTK_VERSION=v0.46.0 \
    sh /tmp/rtk-install.sh && \
    rm --force /tmp/rtk-install.sh && \
    test -x /usr/local/bin/rtk && \
    /usr/local/bin/rtk --version && \
    /usr/local/bin/rtk init -g --codex --copilot --opencode
RUN install --directory --owner=devuser --group=devuser \
    /home/devuser/.local/share \
    /home/devuser/.local/share/opencode \
    /home/devuser/.local/share/tailscale \
    /home/devuser/.local/state
ENV VERCEL_TELEMETRY_DEBUG=0
USER devuser
ENV USER=devuser
ENV HOME=/home/devuser
ENV PATH="/usr/local/bin:${HOME}/.local/bin:${PATH}"
ENV EDITOR=/usr/bin/vi

RUN command -v rtk && rtk --version

WORKDIR /home/devuser/repos

RUN mkdir /home/devuser/.ssh && ssh-keyscan -H github.com >> ~/.ssh/known_hosts

COPY --chown=devuser:devuser dotfiles /home/devuser/devbox/dotfiles

RUN mkdir --parents ~/devbox && \
      ln --symbolic ~/devbox/dotfiles/.inputrc ~/.inputrc && \
      ln --symbolic --force ~/devbox/dotfiles/.bashrc-debian ~/.bashrc && \
      ln --symbolic ~/devbox/dotfiles/tmux/.tmux.conf ~/.tmux.conf

COPY --from=okta-builder /home/devuser/okta-cli/cli/target/okta /usr/local/bin/okta

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
