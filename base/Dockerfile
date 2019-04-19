FROM debian:stretch-slim
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"
ENV TERM xterm-256color

RUN apt-get update && \
      apt-get install --assume-yes --quiet --no-install-recommends git tmux \
      wget curl man ca-certificates sudo build-essential tree locales less \
      python-dev gpg ssh file bash-completion libncurses-dev liblua5.3-dev \
      ctags

# UTF-8 locale (for tmux)
RUN sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && \
      locale-gen en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Create passwordless non-root user account
RUN groupadd --gid 1000 devuser && \
      useradd --uid 1000 --gid devuser --shell /bin/bash \
      --create-home devuser && \
      chgrp --recursive devuser /usr/local && \
      find /usr/local -type d | xargs chmod g+w && \
      printf "devuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/devuser && \
      chmod 0440 /etc/sudoers.d/devuser

# Node, NPM, Yarn
RUN curl -sSL https://deb.nodesource.com/setup_10.x | bash - && \
      apt-get install --assume-yes --quiet --no-install-recommends nodejs && \
      npm install --global yarn

# Racket programming language (CS450)
RUN apt-get install --assume-yes --quiet --no-install-recommends racket

# Java (IT114L)
# Fake the man pages stuff being installed so this doesn't error.
RUN mkdir -pv /usr/share/man/man1
RUN apt-get install --assume-yes --quiet --no-install-recommends openjdk-8-jdk-headless

# Neovim
RUN apt-get install --assume-yes --quiet --no-install-recommends neovim

# Be non-root user
# Note! Docker directives like `RUN` require `sudo` after becoming non-root user. 
USER devuser
ENV HOME /home/devuser
WORKDIR /home/devuser

# Rust
RUN wget --quiet \
      "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init" && \
      chmod +x rustup-init && \
      ./rustup-init -y && \
      rm rustup-init

# Github is a known host
RUN mkdir ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# Act like an abstract base class - this image is not runnable.
CMD ["true"]
