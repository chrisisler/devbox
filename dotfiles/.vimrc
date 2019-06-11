set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

source $HOME/.vim/rc/general-settings.vim
source $HOME/.vim/rc/plugins.vim
source $HOME/.vim/rc/mappings.vim
source $HOME/.vim/rc/misc.vim
source $HOME/.vim/rc/status-line.vim

" `Normal` must be defined before `fg` and `bg` can be set.
highlight Normal ctermfg=7 ctermbg=0
source $HOME/.vim/rc/custom-highlighting.vim
