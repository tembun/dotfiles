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
au BufWinEnter * match ExtraWhitespace /[ 	]\+$/
au InsertEnter * match ExtraWhitespace /[ 	]\+$/
au InsertLeave * match ExtraWhitespace /[ 	]\+$/
au BufWinLeave * call clearmatches()
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

" grep pattern, open results in a quickfix window with highlighting.
" -nargs=+	Custom command Grep may take any number of arguments
" let @/	Save rhs into register '/' (last search pattern register)
" '<args>'	The arguments, passed into a Grep command
" set hlsearch	We saved our search pattern into '/'; this would highlight it.
" silent	Run command w/o result message box that pops up by default.
"       	The crucial part for it to work properly is a 'redraw!' part
"        	in the QuickFixCmdPost (see below), because I figured that when
"        	grepping in silent mode, the real text buffer gets some weird
"        	messy characters in random places.  So force a full screen
"        	redraw every time quickfix window is opened.
" grep! 	grep, but don't jump to the first match right away
command! -nargs=+ Grep call s:Grep(<q-args>)
function! s:Grep(args) abort
    let parts = split(a:args)
    let @/ = parts[0]
    set hlsearch
    if len(parts) == 1
        execute 'grep! -rI' a:args '.'
    else
        execute 'grep! -rI' a:args
    endif
    copen
endfunction
noremap <leader>g :Grep<space>

noremap <leader>t :tabe<CR>
noremap <leader>f :make<CR>
noremap <leader>q :only<CR>
noremap <leader>w :set nowrap!<CR>
noremap <leader>n :norm
noremap <C-n> :cn<CR>
noremap <C-f> :cp<CR>

" Invoke the file of the current buffer and open its output in new split.
function! ExecFile()
	let f = expand('%:p')
	let out = systemlist(f)
	if empty(out)
		return
	endif
	belowright 15new
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
	call setline(1, out)
endfunction
command! ExecFile call ExecFile()
noremap <leader>e :ExecFile<CR>
augroup ShSpecial
	au!
	" Check shell script syntax (current buffer)
	au FileType sh setlocal errorformat=%f:\ %l:\ %m
	au FileType sh setlocal makeprg=sh\ -n\ %
augroup END

iabbrev ddd fprintf(stderr, "%s():%d\n", __func__, __LINE__)
augroup quickfix
    au!
    " Automatic location/quickfix window
    " See comments regarding 'redraw!' in Grep command definition above.
    au QuickFixCmdPost [^l]* 15cwindow |redraw!
    au QuickFixCmdPost    l* lwindow
augroup END
