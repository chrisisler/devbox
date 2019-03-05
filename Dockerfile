FROM chrisisler/devbox
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"

RUN git clone https://github.com/chrisisler/devbox ~/devbox && \
    mkdir -p ~/.vim/autoload ~/.vim/undodir && \
    ln --symbolic ~/devbox/dotfiles/.vimrc ~/.vimrc && \
    ln --symbolic ~/devbox/dotfiles/.vim/rc ~/.vim/rc && \
    ln --symbolic ~/devbox/dotfiles/.vim/snippets ~/.vim/snippets && \
    ln --symbolic ~/devbox/dotfiles/.vim/autoload/plug.vim ~/.vim/autoload/plug.vim && \
    ~/devbox/dotfiles/install-vim-plugins.sh && \
    yarn install --cwd ~/.vim/plugged/tern_for_vim && \
    ln --symbolic ~/devbox/dotfiles/.inputrc ~/.inputrc && \
    ln --symbolic --force ~/devbox/dotfiles/.bashrc-debian ~/.bashrc && \
    ln --symbolic ~/devbox/dotfiles/.tmux.conf ~/.tmux.conf

CMD ["/bin/bash"]
