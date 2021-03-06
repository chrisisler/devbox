set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

source $HOME/.vim/rc/general-settings.vim
source $HOME/.vim/rc/plugins.vim
source $HOME/.vim/rc/mappings.vim

" `Normal` must be defined before `ctermfg/bg` can be used
highlight Normal ctermfg=7 ctermbg=0
source $HOME/.vim/rc/custom-highlighting.vim
source $HOME/.vim/rc/status-line.vim
source $HOME/.vim/rc/misc.vim

" Allow backgrounds to not be `ctermbg=0`. (Must be set last.)
highlight Normal ctermbg=NONE
