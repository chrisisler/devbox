# syntax=docker/dockerfile:1

FROM chrisisler/devbox-base-sys

RUN apt-get update && apt-get install --assume-yes --quiet --no-install-recommends \
    libavcodec-dev libavformat-dev libavutil-dev libavfilter-dev \
    libavdevice-dev libswscale-dev libswresample-dev && \
    rm -rf /var/lib/apt/lists

# Sys: Be non-root user - Warning: affects remaining docker commands.
USER devuser
ENV USER=devuser
ENV HOME=/home/devuser

ENV PATH="${HOME}/.local/bin:${PATH}"
ENV EDITOR=/usr/bin/vi

WORKDIR /home/devuser/habitops

# Free Claude Code and its provider-backed coding-agent wrappers.
# RUN curl --fail --silent --show-error --location \
#     https://raw.githubusercontent.com/Alishahryar1/free-claude-code/main/scripts/install.sh \
#     --output /tmp/free-claude-code-install.sh && \
#     sed --in-place \
#       -e 's/install_claude=1/install_claude=0/g' \
#       -e 's/install_cline=1/install_cline=0/g' \
#       -e 's/install_codex=1/install_codex=1/g' \
#       -e 's/install_dsh=1/install_dsh=0/g' \
#       -e 's/install_aider=1/install_aider=0/g' \
#       -e 's/install_grok=1/install_grok=0/g' \
#       -e 's/install_hermes=1/install_hermes=0/g' \
#       -e 's/install_muse=1/install_muse=0/g' \
#       -e 's/install_opencode=1/install_opencode=1/g' \
#       -e 's/install_pi=1/install_pi=0/g' \
#       /tmp/free-claude-code-install.sh && \
#     sh /tmp/free-claude-code-install.sh --rtk && \
#     rm --force /tmp/free-claude-code-install.sh

RUN mkdir /home/devuser/.ssh && ssh-keyscan -H github.com >> ~/.ssh/known_hosts

CMD ["/bin/bash"]