FROM debian:latest
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"
ENV TERM xterm-256-color

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends \
  git vim tmux wget curl man ca-certificates
# RUN apt-get install -y node

RUN git clone https://github.com/chrisisler/config ~/config

CMD ["/bin/bash"]
