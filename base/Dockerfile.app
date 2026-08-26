# Trixie is current stable; GraalVM below provides the Java 17 toolchain for Okta CLI.
FROM chrisisler/devbox-base-sys

RUN curl -sSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install --assume-yes --quiet --no-install-recommends nodejs lsof && \
    npm install --global typescript && \
    node --version

RUN npm install --global @openai/codex

RUN apt-get update && \
    apt-get install --assume-yes --quiet --no-install-recommends \
    maven zlib1g-dev

# Terraform CLI from the official HashiCorp Debian repository.
RUN set -eux; \
    curl --fail --silent --show-error --location https://apt.releases.hashicorp.com/gpg | \
      gpg --dearmor --yes --output /usr/share/keyrings/hashicorp-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" \
      > /etc/apt/sources.list.d/hashicorp.list; \
    apt-get update; \
    apt-get install --assume-yes --quiet --no-install-recommends terraform; \
    terraform version

# App: Okta CLI's native-image Maven plugin requires a GraalVM JDK.
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

# Sys: Be non-root user - Warning: affects remaining docker commands.
USER devuser
ENV USER=devuser
ENV HOME=/home/devuser
# App:
WORKDIR /home/devuser/habitops

RUN mkdir /home/devuser/.ssh && ssh-keyscan -H github.com >> ~/.ssh/known_hosts

RUN git clone https://github.com/okta/okta-cli.git /home/devuser/okta-cli && \
    cd /home/devuser/okta-cli && \
    mvn clean install -DskipTests

RUN go install "github.com/pressly/goose/v3/cmd/goose@v3.27.3"
RUN go install "github.com/sqlc-dev/sqlc/cmd/sqlc@v1.31.1"

ENV PATH="/home/devuser/okta-cli/cli/target:${PATH}"

CMD ["/bin/bash"]
