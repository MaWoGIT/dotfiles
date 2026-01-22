" --- Compatibility & Appearance ---
set nocompatible
set t_Co=256
set background=dark
syntax on
colorscheme industry 

" --- UI Settings ---
set number
set relativenumber
set showcmd
set ruler
set laststatus=2

" --- Indentation ---
set expandtab
set shiftwidth=4
set softtabstop=4
set autoindent

" --- Search ---
set incsearch
set hlsearch
set ignorecase
set smartcase
set wildmenu
set wildmode=list:longest

" --- Filetype Support ---
filetype on
filetype plugin on
filetype indent on

" --- Status Line (No Plugins Required) ---
set statusline=
set statusline+=\ %F\ %M\ %Y\ %R
set statusline+=%=
set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ row:\ %l\ col:\ %c\ percent:\ %p%%
