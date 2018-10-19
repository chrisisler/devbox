FROM chrisisler/devbox
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"

RUN git clone https://github.com/chrisisler/devbox ~/devbox && \
    mkdir -p ~/.vim/autoload && \
    ln --symbolic ~/devbox/dotfiles/.vimrc ~/.vimrc && \
    ln --symbolic ~/devbox/dotfiles/.vim/rc ~/.vim/rc && \
    ln --symbolic ~/devbox/dotfiles/.vim/autoload/plug.vim ~/.vim/autoload/plug.vim && \
    ln --symbolic --force ~/devbox/dotfiles/.bashrc-debian ~/.bashrc && \
    ln --symbolic ~/devbox/dotfiles/.tmux.conf ~/.tmux.conf 

# Next
# RUN vim +PlugInstall!

# RUN vim +PlugInstall

CMD ["/bin/bash"]
