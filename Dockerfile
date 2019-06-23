FROM chrisisler/devbox-base
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"

# Pull latest dotfiles from github
# Copy inputrc, bashrc, tmux, and neovim configs
RUN git clone --single-branch --branch master https://github.com/chrisisler/devbox ~/devbox && \
      ln --symbolic ~/devbox/dotfiles/.inputrc ~/.inputrc && \
      ln --symbolic --force ~/devbox/dotfiles/.bashrc-debian ~/.bashrc && \
      ln --symbolic ~/devbox/dotfiles/.tmux.conf ~/.tmux.conf && \
      mkdir ~/.vim && \
      ln --symbolic ~/devbox/dotfiles/.vim/rc ~/.vim/rc && \
      mkdir ~/.config && \
      ln --symbolic ~/devbox/dotfiles/.vim ~/.config/nvim && \
      ln --symbolic ~/devbox/dotfiles/.vimrc ~/.config/nvim/init.vim && \
      ln --symbolic ~/.config/nvim/init.vim ~/.vimrc

# Install all plugins (and their dependencies) (see ./dotfiles/.vim/rc/plugins.vim)
RUN vim -V1 -Es -N -i NONE -U NONE -u ~/.config/nvim/init.vim +'PlugInstall --sync' +qa 2>&1
RUN vim -V1 -Es -N -i NONE -U NONE -u ~/.config/nvim/init.vim +UpdateRemotePlugins +qa 2>&1

CMD ["/bin/bash"]
