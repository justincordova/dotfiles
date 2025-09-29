" Enable syntax highlighting
syntax on

" Colorscheme and background
colorscheme github
set background=dark
set termguicolors

" Highlight groups with black background
highlight Normal guibg=#000000
highlight NonText guibg=#000000
highlight LineNr guibg=#000000
highlight SignColumn guibg=#000000
highlight VertSplit guibg=#000000
highlight EndOfBuffer guibg=#000000

" Show absolute line numbers
set number

" Cursor line (optional: disable if you don't want any highlight)
set nocursorline


" Indentation settings
set smartindent
set expandtab       " Use spaces instead of tabs
set shiftwidth=4    " Number of spaces for autoindent
set tabstop=4       " Number of spaces tabs count for

" Other UI and behavior settings
set wildmenu
set undofile
set splitright
set clipboard=unnamedplus    " Use system clipboard
set mouse=a                  " Enable mouse support
