FROM debian:stable
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"
ENV TERM xterm-256color

RUN apt-get update && \
      apt-get install --assume-yes --quiet --no-install-recommends git tmux \
      wget curl man ca-certificates sudo build-essential tree locales less \
      gpg gpg-agent ssh file bash-completion neovim xclip python3-neovim \
      python3-pip python3-setuptools tig

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

# Github is a known host
RUN mkdir ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

RUN curl -sSL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install --assume-yes --quiet --no-install-recommends npm nodejs && \
    npm install --global yarn typescript neovim tern

# Neovim dependency
RUN pip3 install wheel
RUN pip3 install --upgrade pynvim

# Be non-root user
# Warning: This affects all future commands!
USER devuser
ENV USER devuser
ENV HOME /home/devuser
WORKDIR /home/devuser

# Rust language
RUN wget --quiet \
      "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init" && \
      chmod +x rustup-init && \
      ./rustup-init -y 2>&1 && \
      rm rustup-init

RUN curl -sfLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

CMD ["/bin/bash"]
