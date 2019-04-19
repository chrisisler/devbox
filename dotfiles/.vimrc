" Make Neovim internals understand Vim internals (or something)
set runtimepath^=~/.vim
let &packpath = &runtimepath

source $HOME/.vim/rc/general-settings.vim
source $HOME/.vim/rc/plugins.vim
source $HOME/.vim/rc/mappings.vim
source $HOME/.vim/rc/misc.vim
source $HOME/.vim/rc/status-line.vim

" Neovim requires `Normal` to be defined before the `fg` and `bg` values can
" be used.
highlight Normal ctermfg=7 ctermbg=0
source $HOME/.vim/rc/custom-highlighting.vim
