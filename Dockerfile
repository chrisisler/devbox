FROM chrisisler/devbox-neovim-base
LABEL maintainer="Chris Isler <christopherisler1@gmail.com>"

# Pull dotfiles from github
RUN git clone --single-branch --branch neovim https://github.com/chrisisler/devbox ~/devbox

# Copy config for inputrc, bashrc, and tmux config
RUN ln --symbolic ~/devbox/dotfiles/.inputrc ~/.inputrc && \
      ln --symbolic --force ~/devbox/dotfiles/.bashrc-debian ~/.bashrc && \
      ln --symbolic ~/devbox/dotfiles/.tmux.conf ~/.tmux.conf

# Install Neovim plugin manager `vim-plug` (https://github.com/junegunn/vim-plug)
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Neovim config
RUN mkdir -p ~/.config && \
      mkdir ~/.vim && ln --symbolic ~/devbox/dotfiles/.vim/rc ~/.vim/rc && \
      ln --symbolic ~/devbox/dotfiles/.vim ~/.config/nvim && \
      ln --symbolic ~/devbox/dotfiles/.vimrc ~/.config/nvim/init.vim && \
      ln --symbolic ~/.config/nvim/init.vim ~/.vimrc

# Install all plugins (and their dependencies) non-interactively
RUN sudo apt-get install --assume-yes --quiet --no-install-recommends python3-pip python3-setuptools
RUN pip3 install --upgrade pip && \
      pip3 install --user --upgrade pynvim
RUN vim -Es -N -i NONE -U NONE -u ~/.config/nvim/init.vim +'PlugInstall --sync' +qa
RUN vim -Es -N -i NONE -U NONE -u ~/.config/nvim/init.vim +'UpdateRemotePlugins --sync' +qa

# EXPOSE 3000

CMD ["/bin/bash"]
