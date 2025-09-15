syntax enable
syntax on
set number
highlight Normal guibg=#000000
highlight NonText guibg=#000000
highlight LineNr guibg=#000000
highlight SignColumn guibg=#000000
highlight VertSplit guibg=#000000
highlight EndOfBuffer guibg=#000000
set smartindent
set wildmenu
set undofile
set splitright
set clipboard=unnamedplus " Use system clipboard
set mouse=a              " Enable mouse support

call plug#begin()                              " Initialize vim-plug plugin system&#8203;:contentReference[oaicite:9]{index=9}
Plug 'projekt0n/github-nvim-theme'             " GitHub Dark theme plugin&#8203;:contentReference[oaicite:10]{index=10}
call plug#end()                                " End plugin section (loads the plugins)

" Enable truecolor support and apply the theme:
set termguicolors                             " Enable 24-bit colors in the terminal&#8203;:contentReference[oaicite:11]{index=11}
colorscheme github_dark                       " Activate the GitHub Dark colorscheme&#8203;:contentReference[oaicite:12]{index=12}

set background=dark
highlight Normal ctermbg=black guibg=black

