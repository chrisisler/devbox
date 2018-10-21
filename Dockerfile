FROM chrisisler/devbox
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"

RUN git clone https://github.com/chrisisler/devbox ~/devbox && \
    mkdir -p ~/.vim/autoload && \
    ln --symbolic ~/devbox/dotfiles/.vimrc ~/.vimrc && \
    ln --symbolic ~/devbox/dotfiles/.vim/rc ~/.vim/rc && \
    ln --symbolic ~/devbox/dotfiles/.vim/snippets ~/.vim/snippets && \
    ln --symbolic ~/devbox/dotfiles/.vim/autoload/plug.vim ~/.vim/autoload/plug.vim && \
    ~/devbox/dotfiles/install-vim-plugins.sh && \
    ln --symbolic ~/devbox/dotfiles/.inputrc ~/.inputrc && \
    ln --symbolic --force ~/devbox/dotfiles/.bashrc-debian ~/.bashrc && \
    ln --symbolic ~/devbox/dotfiles/.tmux.conf ~/.tmux.conf

# Rainbowstream (Twitter CLI client)
# 1) Install pip
#   - https://pip.pypa.io/en/stable/installing/
#   - curl https://bootstrap.pypa.io/get-pip.py -sSo get-pip.py && python get-pip.py
# 2) Install Rainbowstream
#   - https://github.com/orakaro/rainbowstream
#   - (sudo) pip install rainbowstream
# RUN ln --symbolic ~/devbox/dotfiles/.rainbow_config.json ~/.rainbow_config.json

# Tmuxline
# - Any package updates available?
# - Num of installed packages
# - Amount of memory remaining

CMD ["/bin/bash"]
