FROM chrisisler/devbox
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"

# `make dotfiles`

RUN git clone https://github.com/chrisisler/devbox ~/devbox && \
    mkdir -p ~/.vim/autoload && \
    ln --symbolic ~/devbox/dotfiles/.vimrc ~/.vimrc && \
    ln --symbolic ~/devbox/dotfiles/.vim/rc ~/.vim/rc && \
    ln --symbolic ~/devbox/dotfiles/.vim/autoload/plug.vim ~/.vim/autoload/plug.vim && \
    ln --symbolic --force ~/devbox/dotfiles/.bashrc-debian ~/.bashrc && \
    ln --symbolic ~/devbox/dotfiles/.bash_functions ~/.bash_functions

# RUN vim +PlugInstall

CMD ["/bin/bash"]
