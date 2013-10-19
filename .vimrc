" =======================================================================
"     General
" =======================================================================

syntax on
let mapleader=","
set number
set mouse=a
set guioptions-=r
set guioptions-=L
set guioptions-=e
set guifont=Monaco\ for\ Powerline:h12
set linespace=1 
set hidden
set wrap!
set encoding=utf-8 nobomb
set history=999
set undolevels=999
set nobackup
set nowritebackup
set noswapfile
set laststatus=2
set ai
set lcs=tab:>-,eol:$
set list
set incsearch
set hlsearch
set ignorecase
set smartcase
set expandtab ""Insert space chars instead of tab
set autoindent smartindent "Make identind stuff easier
set copyindent
set tabstop=4 ""Default number of spaces a tab takes
set shiftwidth=4
set softtabstop=4 "Allow deletion of whole tabs
set backspace=indent,eol,start
set clipboard+=unnamed
set wildignore=*.o,*.obj,.git,*.png,*.PNG,*.JPG,*.jpg,*.GIF,*.gif,*.pdf,*.PDF,*.pyc,*.swp,*.bak
autocmd Filetype html,htmldjango,eruby,ruby,xml,phtml,ctp set expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd Filetype js,javascript,php set expandtab shiftwidth=4 tabstop=4 softtabstop=4
call pathogen#infect()

"JS Lint
set makeprg=jsl\ -nologo\ -nofilelisting\ -nosummary\ -nocontext\ -conf\ '<DIRECTORY_PATH>/jsl.conf'\ -process\ %
set errorformat=%f(%l):\ %m^M

" =======================================================================
"     Mappings
" =======================================================================

imap <C-h> <C-o>h
imap <C-j> <C-o>j
imap <C-k> <C-o>k
imap <C-l> <C-o>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <silent> <tab> <C-^>
nnoremap <leader>vrc :e ~/.vimrc<CR>
nnoremap <leader>so :so %<CR>
nnoremap <leader><tab> :NERDTreeToggle<cr>
nnoremap <leader>g :CommandT<cr>
nnoremap <leader>h :CommandTBuffer<cr>
nnoremap <leader>u :GundoToggle<cr>
nnoremap : ;
nnoremap ; :
let g:EasyMotion_leader_key = '<Leader>'

" =======================================================================
"     Styling
" =======================================================================

colorscheme Molokai
let g:airline_theme='powerlineish'

let g:airline#extensions#tabline#enabled = 1
let g:airline_left_sep=''
let g:airline_right_sep=''


if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" old vim-powerline symbols
let g:airline_left_sep = '⮀'
let g:airline_left_alt_sep = '⮁'
let g:airline_right_sep = '⮂'
let g:airline_right_alt_sep = '⮃'
let g:airline_symbols.branch = '⭠'
let g:airline_symbols.readonly = '⭤'
let g:airline_symbols.linenr = '⭡'
