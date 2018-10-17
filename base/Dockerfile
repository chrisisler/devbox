FROM debian:latest
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"
ENV TERM xterm-256color

# Install base packages
RUN apt-get update
RUN apt-get install --assume-yes --quiet --no-install-recommends \
      git tmux wget curl man ca-certificates sudo build-essential

# Install Vim dependencies
RUN apt-get install --assume-yes --quiet --no-install-recommends \
      libncurses-dev liblua5.3-dev python-dev

# Vim: download source, configure dependencies, then install
WORKDIR /usr/include/lua5.3
RUN mkdir include && cp ./*.h include && \
      ln -s /usr/lib/x86_64-linux-gnu/liblua5.3.so /usr/local/lib/liblua.so
WORKDIR /usr/local/lib
RUN git clone https://github.com/vim/vim.git
RUN cd vim/src && ./configure --enable-fail-if-missing --with-lua-prefix=/usr/include/lua5.3 \
      --enable-luainterp=yes --enable-pythoninterp=yes && \
      make && make install

# Be passwordless non-root user
RUN groupadd --gid 1000 devuser && \
      useradd --uid 1000 --gid devuser --shell /bin/bash --create-home devuser && \
      chgrp --recursive devuser /usr/local && \
      find /usr/local -type d | xargs chmod g+w && \
      printf "devuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/devuser && \
      chmod 0440 /etc/sudoers.d/devuser

USER devuser
ENV HOME /home/devuser
WORKDIR /home/devuser

CMD ["/bin/bash"]
