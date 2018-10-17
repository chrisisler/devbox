FROM chrisisler/devbox
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"

RUN git clone https://github.com/chrisisler/devbox ~/devbox
RUN mkdir -p ~/.vim/autoload && \
    ln --symbolic ~/devbox/dotfiles/.vimrc ~/.vimrc && \
    ln --symbolic ~/devbox/dotfiles/.vim/rc ~/.vim/rc && \
    ln --symbolic ~/devbox/dotfiles/.vim/autoload/plug.vim ~/.vim/autoload/plug.vim && \
    rm ~/.bashrc && cp ~/devbox/dotfiles/.bashrc-debian ~/.bashrc
    # ln --symbolic --force ~/devbox/dotfiles/.bashrc-debian ~/.bashrc

# RUN vim +PlugInstall

CMD ["/bin/bash"]
