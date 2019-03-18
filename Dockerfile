FROM chrisisler/devbox
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"

# Clone dotfiles
RUN git clone https://github.com/chrisisler/devbox ~/devbox

# Copy config for inputrc, bashrc, and tmuxrc
RUN ln --symbolic ~/devbox/dotfiles/.inputrc ~/.inputrc && \
      ln --symbolic --force ~/devbox/dotfiles/.bashrc-debian ~/.bashrc && \
      ln --symbolic ~/devbox/dotfiles/.tmux.conf ~/.tmux.conf

# Copy config for Neovim
RUN mkdir ~/.config && \
      mkdir -p ~/.vim/autoload ~/.vim/undodir && \
      ln --symbolic ~/devbox/dotfiles/.vim ~/.config/nvim && \
      ln --symbolic ~/devbox/dotfiles/.vimrc ~/.config/vimrc && \
      ln --symbolic ~/devbox/dotfiles/.vim/snippets ~/.vim/snippets && \
      ln --symbolic ~/devbox/dotfiles/.vim/autoload/plug.vim ~/.vim/autoload/plug.vim && \
      ~/devbox/dotfiles/install-neovim-plugins.sh && \
      yarn install --cwd ~/.vim/plugged/tern_for_vim

# RUN git clone https://github.com/chrisisler/devbox ~/devbox && \
#     mkdir -p ~/.vim/autoload ~/.vim/undodir && \
#     ln --symbolic ~/devbox/dotfiles/.vimrc ~/.vimrc && \
#     ln --symbolic ~/devbox/dotfiles/.vim/rc ~/.vim/rc && \
#     ln --symbolic ~/devbox/dotfiles/.vim/snippets ~/.vim/snippets && \
#     ln --symbolic ~/devbox/dotfiles/.vim/autoload/plug.vim ~/.vim/autoload/plug.vim && \
#     ~/devbox/dotfiles/install-vim-plugins.sh && \
#     yarn install --cwd ~/.vim/plugged/tern_for_vim

CMD ["/bin/bash"]
