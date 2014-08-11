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
set guifont=Monaco:h12
set linespace=2
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
set hlsearch ""Continue to highlight searched phrases.
set incsearch ""But do highlight as you type your search.
set ignorecase
set smartcase
set expandtab ""Insert space chars instead of tab
set autoindent smartindent "Make identind stuff easier
set copyindent
set tabstop=4 ""Default number of spaces a tab takes
set shiftwidth=4
set softtabstop=4 ""Allow deletion of whole tabs
set backspace=indent,eol,start
set clipboard+=unnamed
set wildignore=*.o,*.obj,.git,*.png,*.PNG,*.JPG,*.jpg,*.GIF,*.gif,*.pdf,*.PDF,*.pyc,*.swp,*.bak
autocmd Filetype html,htmldjango,eruby,ruby,xml,phtml,ctp set expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd Filetype js,javascript,php set expandtab shiftwidth=4 tabstop=4 softtabstop=4
au BufReadPost *.eco set syntax=html
au BufReadPost *.stylus set syntax=css
call pathogen#infect()

"JS Lint
set makeprg=jsl\ -nologo\ -nofilelisting\ -nosummary\ -nocontext\ -conf\ '<DIRECTORY_PATH>/jsl.conf'\ -process\ %
set errorformat=%f(%l):\ %m^M

"Tmux fix
set t_ut=

" =======================================================================
"     Mappings
" =======================================================================

imap <C-h> <C-o>h
imap <C-j> <C-o>j
imap <C-k> <C-o>k
imap <C-l> <C-o>l

" Moving selection
xmap <C-k> :mo'<-- <CR> gv
xmap <C-j> :mo'>+ <CR> gv

" Tab indents selection
vmap <silent> <Tab> >gv
" Shift-tab unindents
vmap <silent> <S-Tab> <gv

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <silent> <tab> <C-^>
nnoremap <leader>vrc :e ~/.vimrc<CR>
nnoremap <leader>zsh :e ~/.zshrc<CR>
nnoremap <leader>so :so %<CR>
nnoremap <leader><tab> :NERDTreeToggle<cr>
nnoremap <leader>g :CommandT<cr>
nnoremap <leader>h :CommandTBuffer<cr>
nnoremap <leader>u :GundoToggle<cr>
nnoremap : ;
nnoremap ; :
" Smooth scroll
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>

let g:EasyMotion_leader_key = '<Leader>'
" Mapping for emmet trigger
imap hh <C-y>,

" =======================================================================
"     Styling
" =======================================================================

colorscheme Tomorrow-Night
"set background=light

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
