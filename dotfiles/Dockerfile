FROM chrisisler/devbox
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"

RUN git clone https://github.com/chrisisler/devbox ~/devbox && \
    ln -s ~/devbox/dotfiles/.vimrc ~/.vimrc && \
    ln -s ~/devbox/dotfiles/.vim/rc ~/.vim/rc

# RUN vim +PlugInstall

CMD ["/bin/bash"]
