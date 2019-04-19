FROM chrisisler/devbox-neovim-base
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"

# Pull latest dotfiles from github master
# TODO When we push neovim branch master, uncomment the line below
# RUN git clone https://github.com/chrisisler/devbox ~/devbox
RUN git clone --single-branch --branch neovim https://github.com/chrisisler/devbox ~/devbox

# Copy config for inputrc, bashrc, and tmux config
RUN ln --symbolic ~/devbox/dotfiles/.inputrc ~/.inputrc && \
      ln --symbolic --force ~/devbox/dotfiles/.bashrc-debian ~/.bashrc && \
      ln --symbolic ~/devbox/dotfiles/.tmux.conf ~/.tmux.conf

# Install Neovim plugin manager `vim-plug` (https://github.com/junegunn/vim-plug)
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Neovim configuration (from Vim)
# TODO
# - UltiSnips requires py >= 2.7 or py3
# - Snippets
# - Autocompletion
RUN mkdir ~/.config && \
      mkdir ~/.vim && ln --symbolic ~/devbox/dotfiles/.vim/rc ~/.vim/rc && \
      ln --symbolic ~/devbox/dotfiles/.vim ~/.config/nvim && \
      ln --symbolic ~/devbox/dotfiles/.vimrc ~/.config/nvim/init.vim && \
      ~/devbox/dotfiles/install-neovim-plugins.sh


#       ln --symbolic ~/devbox/dotfiles/.vim/snippets ~/.vim/snippets && \


# RUN mkdir ~/.config && \
#       mkdir -p ~/.vim/autoload ~/.vim/undodir && \
#       ln --symbolic ~/devbox/dotfiles/.vim ~/.config/nvim && \
#       ln --symbolic ~/devbox/dotfiles/.vimrc ~/.config/vimrc && \
#       ln --symbolic ~/devbox/dotfiles/.vim/snippets ~/.vim/snippets && \
#       ln --symbolic ~/devbox/dotfiles/.vim/autoload/plug.vim ~/.vim/autoload/plug.vim && \
#       ~/devbox/dotfiles/install-neovim-plugins.sh && \
#       yarn install --cwd ~/.vim/plugged/tern_for_vim

# RUN git clone https://github.com/chrisisler/devbox ~/devbox && \
#     mkdir -p ~/.vim/autoload ~/.vim/undodir && \
#     ln --symbolic ~/devbox/dotfiles/.vimrc ~/.vimrc && \
#     ln --symbolic ~/devbox/dotfiles/.vim/rc ~/.vim/rc && \
#     ln --symbolic ~/devbox/dotfiles/.vim/snippets ~/.vim/snippets && \
#     ln --symbolic ~/devbox/dotfiles/.vim/autoload/plug.vim ~/.vim/autoload/plug.vim && \
#     ~/devbox/dotfiles/install-vim-plugins.sh && \
#     yarn install --cwd ~/.vim/plugged/tern_for_vim

CMD ["/bin/bash"]
