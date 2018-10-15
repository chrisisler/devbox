FROM debian:latest
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"
ENV TERM xterm-256color

RUN apt-get update
RUN apt-get install --assume-yes --quiet --no-install-recommends \
      git vim tmux wget curl man ca-certificates sudo

# 1000 or 999?
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
