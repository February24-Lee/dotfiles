set number
set relativenumber number
set tabstop=4
set shiftwidth=4
set expandtab
set ignorecase
set smartcase
set nocompatible
set hidden
set nocp
set ignorecase smartcase
set wrapscan
filetype plugin on
set rtp+=/opt/homebrew/opt/fzf
syntax on

call plug#begin()
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', {'do': { -> fzf#install() } }
Plug 'sheerun/vim-polyglot'
Plug 'preservim/nerdtree'
call plug#end()

nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <Leader>f :Rg<CR>
inoremap jj <Esc>
inoremap jk <Esc>
