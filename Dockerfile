FROM debian:latest
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"
ENV TERM xterm-256color

# Install basics
RUN apt-get update
RUN apt-get install --assume-yes --quiet --no-install-recommends \
      git vim tmux wget curl man ca-certificates

# Install Vim plugin manager `vim-plug`
# RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
#       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Clone dotfiles
RUN git clone https://github.com/chrisisler/devbox /devbox
RUN ln -s /devbox/dotfiles/.vimrc ~/.vimrc
RUN ln -s /devbox/dotfiles/.vim/rc ~/.vim/rc

# Install Vim plugins
# RUN vim +PlugInstall

CMD ["/bin/bash"]
