FROM chrisisler/devbox
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"

# RUN git clone https://github.com/chrisisler/devbox ~/devbox
RUN git clone https://github.com/chrisisler/devbox ~/devbox && \
    ln --symbolic ~/devbox/dotfiles/.vimrc ~/.vimrc && \
    mkdir -p ~/.vim && \
    ln --symbolic ~/devbox/dotfiles/.vim/rc ~/.vim/rc && \
    ln --symbolic ~/devbox/dotfiles/.vim/autoload ~/.vim/autoload

# RUN vim +PlugInstall

CMD ["/bin/bash"]
