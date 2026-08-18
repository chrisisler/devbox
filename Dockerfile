FROM alpine:stable
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"
ENV TERM=xterm-256color

RUN apk add --no-cache \
      git tmux wget curl man ca-certificates sudo tree less \
      gpg gpg-agent ssh file bash-completion xclip tig gh golang vi

# Create passwordless non-root user account
RUN addgroup --gid 1000 devuser && \
      adduser --uid 1000 --gid devuser --shell /bin/bash \
      --create-home devuser && \
      chgrp --recursive devuser /usr/local && \
      find /usr/local -type d | xargs chmod g+w && \
      printf "devuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/devuser && \
      chmod 0440 /etc/sudoers.d/devuser

# Github is a known host
RUN ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

RUN curl -sSL https://deb.nodesource.com/setup_24.x | bash - && \
    apk add --no-cache nodejs && \
    npm install --global yarn typescript && \
    node --version

RUN npm install --global @github/copilot

# Be non-root user
# Warning: This affects all future commands!
USER agentuser
ENV USER=agentuser
ENV HOME=/home/agentuser
WORKDIR /home/agentuser

CMD ["/bin/bash"]
