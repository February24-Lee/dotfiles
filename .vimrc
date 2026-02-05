set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set ignorecase
set smartcase
set nocompatible
set hidden
set wrapscan
filetype plugin on
syntax on

" macOS(Homebrew)에서만 fzf 경로 추가
if system("uname") =~ "Darwin" && system("command -v brew") != ""
    set rtp+=/opt/homebrew/opt/fzf
endif

call plug#begin()
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', {'do': { -> fzf#install() } }
Plug 'sheerun/vim-polyglot'
Plug 'preservim/nerdtree'
Plug 'preservim/tagbar'
Plug 'vim-airline/vim-airline'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-autoformat/vim-autoformat'
call plug#end()

nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <Leader>f :Rg<CR>
inoremap jj <Esc>
inoremap jk <Esc>
