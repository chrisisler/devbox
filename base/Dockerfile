FROM debian:stable-slim
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"
ENV TERM=xterm-256color

RUN apt-get update && \
      apt-get install --assume-yes --quiet --no-install-recommends git tmux golang \
      wget curl man ca-certificates sudo build-essential tree locales less gh vim \
      gpg gpg-agent ssh file bash-completion xclip python3-pip python3-setuptools tig

# Create passwordless non-root user account
RUN groupadd --gid 1000 devuser && \
      useradd --uid 1000 --gid devuser --shell /bin/bash \
      --create-home devuser && \
      chgrp --recursive devuser /usr/local && \
      find /usr/local -type d | xargs chmod g+w && \
      printf "devuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/devuser && \
      chmod 0440 /etc/sudoers.d/devuser

# Github is a known host
RUN ssh-keyscan -H github.com >> ~/.ssh/known_hosts

RUN curl -sSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install --assume-yes --quiet --no-install-recommends nodejs lsof && \
    npm install --global typescript && \
    node --version

RUN npm install --global @github/copilot

RUN printf "[user]\nname = Chris I\nemail = isl.chr@proton.me" > ~/.gitconfig

RUN sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && \
      locale-gen en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Be non-root user
# Warning: This affects all future commands (for the rest of *this* Dockerfile)
USER devuser
ENV USER=devuser
ENV HOME=/home/devuser
WORKDIR /home/devuser/habitops

RUN go install "github.com/pressly/goose/v3/cmd/goose@v3.27.3"
RUN go install "github.com/sqlc-dev/sqlc/cmd/sqlc@v1.31.1"

CMD ["/bin/bash"]
