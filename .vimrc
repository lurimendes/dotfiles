:syntax on

:let mapleader=","

:set number
:set tabstop=4
:set mouse=a
:set guioptions-=r
:set guioptions-=L
:set guifont=Monaco:h12

:set wrap!

call pathogen#infect()
" Give a shortcut key to NERD Tree
nnoremap <leader><tab> :NERDTreeToggle<cr>
" Shortcut to CommandT
nnoremap <leader>g :CommandT<cr>
nnoremap <leader>h :CommandTBuffer<cr>
"set syn=slate


" move the cursor in insert mode
imap <C-h> <C-o>h
imap <C-j> <C-o>j
imap <C-k> <C-o>k
imap <C-l> <C-o>l


" Restore Easy motion to one comma 
let g:EasyMotion_leader_key = '<Leader>'


"set nocompatible ""Disable vi compatibility
"filetype on "Avoid Pathogem bugs
"filetype off "Reload pahotogem funcionality
"call pathogen#runtime_append_all_bundles() "Plugin init

"set nu

"Mouse Scroller
"set mouse=nicr

"Colorscheme 
let g:solarized_visibility="low"
colorscheme solarized
let g:Powerline_symbols = 'fancy'
let g:Powerline_theme='long'
let g:Powerline_colorscheme='solarized16_dark'

"Layout format
set nu
set ai
set lcs=tab:>-,eol:$
set list
set incsearch ""Set incremental search
set hlsearch ""Highlight search results
set ignorecase ""Ignore capital letters when searching in all lower case
set smartcase ""Search using capital letter if a capital letter was typed on search
set encoding=utf-8 nobomb ""Avoids BOM and make sure to always use utf-8

""More custom options
set history=999
set undolevels=999
set nobackup
set nowritebackup
set noswapfile
set laststatus=2

""Formating
set expandtab ""Insert space chars instead of tab
set autoindent smartindent "Make identind stuff easier
set copyindent
set tabstop=4 ""Default number of spaces a tab takes
set shiftwidth=4
set softtabstop=4 "Allow deletion of whole tabs
set backspace=indent,eol,start
set wildignore+=*.svn,*.hg,*.git,*.pyc ""Ignore all this extension files

"Activate different settings for different file types
autocmd Filetype html,htmldjango,xml,phtml,ctp set noexpandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd Filetype js,javascript,php set noexpandtab shiftwidth=4 tabstop=4 softtabstop=4

set clipboard+=unnamed

"Set the leader to comma
"let mapleader =","
"let g:mapleader=","

"let g:EasyMotion_leader_key = '<leader>'

"Make ctrl+hjkl switch between splited screens
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

"Remap tab on normal mode to switch between buffers
nnoremap <silent> <tab> <C-^>

"Remap tab on normal mode to switch between buffers
nnoremap <silent> <leader><tab> :NERDTreeToggle<cr>

"JSLINT
set makeprg=jsl\ -nologo\ -nofilelisting\ -nosummary\ -nocontext\ -conf\ '<DIRECTORY_PATH>/jsl.conf'\ -process\ %
set errorformat=%f(%l):\ %m^M


