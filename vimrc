call plug#begin()
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'itchyny/vim-highlighturl'
Plug 'tpope/vim-commentary'
call plug#end()
runtime! ftplugin/man.vim

set autoindent
set autowrite 		" Automatically save the file when other program modifies it
set backupcopy=yes
set directory=$HOME/.vimswap//
set display=lastline 	" Display as much as possible of the last line even if it doesn't fit
set foldmethod=manual 	" Folds must be created manually.
set formatoptions=tcq
set hidden
set history=10000
set hlsearch 		" Highlight search terms.
set incsearch 		" Set incremental search
set laststatus=2 	" Always display filename
set lbr! 		" Wrap lines at word boundaries.
set number
set relativenumber
set ruler 		" Display my position in the bottom right of the window.
set scrolloff=5 	" Keep a minimum of 5 lines above and below the cursor.
set shiftwidth=8
set smartindent
set statusline+=%F%10v 	" Display full filepath
set tabstop=8
set textwidth=80
set wrap
set wrapscan 		" Come back to the first search match after the last one
" Settings for autocompletion menu (C-n and C-p).
" menuone - show autocompletion menu even if there's only one match
" noinset - effectively it allows to get back to your original text when
"           cancelling the autocomplete with C-e.  It still does insert text
"           under the cursor while cycling through autocomplete options.
set completeopt=menuone

set t_Co=256
set t_md=
syntax on
colorscheme monochrome
hi ExtraWhitespace ctermbg=130
match ExtraWhitespace /[ 	]\+$/
autocmd BufWinEnter * match ExtraWhitespace /[ 	]\+$/
autocmd InsertEnter * match ExtraWhitespace /[ 	]\+$/
autocmd InsertLeave * match ExtraWhitespace /[ 	]\+$/
autocmd BufWinLeave * call clearmatches()
hi LineNr term=NONE cterm=NONE
let g:highlighturl_ctermfg = 184
let g:highlighturl_underline = 0
set splitbelow
set splitright
hi MatchParen ctermfg=226 ctermbg=16

set mouse=
set noesckeys

inoremap jk <esc>

" Clear the highlighting after the search/substitution
nnoremap <silent> <C-L> :nohlsearch<CR>

" Frequent typos.
command W write
command Q quit
command Wq write | quit
command WQ write | quit

map Y y$
command Eva .write !sh

filetype on
filetype plugin on
filetype indent on

" Custom commands
"
" Open fzf files
noremap <C-p> :Files<CR>
" Open fzf openned buffers
noremap <leader>b :Buffers<CR>
let g:fzf_preview_window = []
" The fzf search window should be located at the bottom and take up 10 rows
let g:fzf_layout = { 'down': '10' }

" Comment/uncomment lines
noremap <leader>/ :Commentary<CR>

noremap <leader>t :tabe<CR>
iabbrev ddd printf("%s():%d\n", __func__, __LINE__)
augroup quickfix
    autocmd!
    " Automatic location/quickfix window
    autocmd QuickFixCmdPost [^l]* 10cwindow
    autocmd QuickFixCmdPost    l* lwindow
augroup END
