FROM debian:testing
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"
ENV TERM xterm-256color

RUN apt-get update && \
      apt-get install --assume-yes --quiet --no-install-recommends git tmux \
      wget curl man ca-certificates sudo build-essential tree locales less \
      gpg gpg-agent ssh file bash-completion ctags neovim python-neovim \
      xclip python3-neovim 

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

# Rust
RUN wget --quiet \
      "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init" && \
      chmod +x rustup-init && \
      ./rustup-init -y 2>&1 && \
      rm rustup-init

# Github is a known host
RUN mkdir ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# Node, NPM, Yarn, and global packages
RUN curl -sSL https://deb.nodesource.com/setup_10.x | bash - && \
      apt-get install --assume-yes --quiet --no-install-recommends nodejs && \
      npm install --global add yarn typescript neovim tern

# Be non-root user
# Note! Docker directives like `RUN` require `sudo` after becoming non-root user. 
USER devuser
ENV USER devuser
ENV HOME /home/devuser
WORKDIR /home/devuser

# Neovim plugin dependencies
# RUN pip3 install --upgrade pip && \
#       pip3 install --user --upgrade pynvim

# Install Neovim plugin manager
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Act like an abstract base class - this image is not runnable.
CMD ["true"]
