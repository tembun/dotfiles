let vimdir = expand('$HOME/.vim/')
if !isdirectory(vimdir)
	call mkdir(vimdir, 'p')
endif

" Install third-party plugins
"
if filereadable(vimdir . 'autoload/plug.vim')
	call plug#begin()
	Plug 'junegunn/fzf'		" fzf native plugin
	Plug 'junegunn/fzf.vim'		" vim fzf integration
	Plug 'itchyny/vim-highlighturl'	" Highligh urls
	Plug 'tpope/vim-commentary'	" Easily comment source code
	Plug 'tpope/vim-fugitive'	" vim git integration
	Plug 'prabirshrestha/vim-lsp'	" vim LSP integration
	call plug#end()
endif

" Base settings
"
set autoindent
set autowrite 		" Automatically save the file when other program modifies it
set backupcopy=yes
set completeopt=menuone	" Show autocompletion menu even for a single match
set display=lastline 	" Display as much as possible of the last line
set exrc
set foldmethod=manual 	" Folds must be created manually
set formatoptions=trcq
set hidden
set history=10000
set hlsearch 		" Highlight search terms
set ignorecase
set incsearch 		" Set incremental search
set laststatus=2 	" Always display filename
set lbr! 		" Wrap lines at word boundaries
set mouse=		" Disable mouse support
set noesckeys
set number		" Display line numbers on the left side
set relativenumber	" Make line numbers relative to the line
set ruler 		" Display my position in the bottom right of the window
set scrolloff=5 	" Keep a minimum of 5 lines above and below the cursor
set shiftwidth=8	" Applies to =, > and < alignment
set signcolumn=no
set smartcase
set smartindent
set splitbelow
set splitright
set statusline=%F%10v 	" Display filepath and screen column number in status line
set tabstop=8		" Tab width for a tab stop
set textwidth=80	" The width at which switch to a new line
set wrap
set wrapscan 		" Come back to the first search match after the last one

let swapdir = vimdir . '.swap'
if !isdirectory(swapdir)
	call mkdir(swapdir, 'p', 0770)
endif
let &directory = swapdir . '//'

" Colorizing things
"
set t_Co=256
set t_md=
syntax on
color monochrome
hi ExtraWhitespace ctermbg=130
match ExtraWhitespace /[ 	]\+$/
au BufWinEnter * match ExtraWhitespace /[ 	]\+$/
au InsertEnter * match ExtraWhitespace /[ 	]\+$/
au InsertLeave * match ExtraWhitespace /[ 	]\+$/
au BufWinLeave * call clearmatches()
hi LineNr term=NONE cterm=NONE
let g:highlighturl_ctermfg = 184
let g:highlighturl_underline = 0
hi MatchParen ctermfg=226 ctermbg=16

" Mappings
"

" Classic :)
inoremap jk <ESC>
map Y y$
nnoremap <silent> <C-L> :nohls<CR>|	" Clear highlight after search/replace

" Resizing the windows
nnoremap <C-Up> :res +2<CR>
nnoremap <C-Down> :res -2<CR>
nnoremap <C-Left> :vert res +2<CR>
nnoremap <C-Right> :ver res -2<CR>

" Frequent typos
com! W write
com! Q quit
com! Wq write | quit
com! WQ write | quit

filetype on
filetype plugin on
filetype indent on

" Custom commands
"
nnoremap <C-p> :Files<CR>|	" fzf through all files in the search path
noremap <leader>c :Buffers<CR>|	" fzf through all opened buffers
let g:fzf_preview_window = []
let g:fzf_layout = { 'down': '10' }	" Where fzf window is located

noremap <leader>/ :Commentary<CR>|	" {Un}comment lines

set grepprg=rg\ --vimgrep\ --smart-case
com! -nargs=+ Sea call Sea(<q-args>)
func! Sea(args) abort
	" Remember the buffer and the position we were at when we initiated the
	" search.  If after jumping through the results (which changes our
	" active buffer) we want to get back to the place where we were (to
	" continue the work) we can make use of SeaOrig().
	let g:grep_origin = [bufnr('%'), getcurpos()]
	let parts = split(a:args)
	let @/ = parts[0]
	set hlsearch
	if len(parts) == 1
		execute 'silent grep! --vimgrep --color=never --smart-case' shellescape(parts[0]) '.'
	else
		execute 'silent grep! --vimgrep --color=never --smart-case' a:args
	endif
	copen
endfunc
func! SeaOrig() abort
	execute 'buffer' g:grep_origin[0]
	call setpos('.', g:grep_origin[1])
endfunc
nnoremap <silent> <leader>p :call SeaOrig()<CR>

nnoremap <leader>f :Sea<Space>
nnoremap <leader>* :Sea<Space><C-R><C-W><CR>|	" Search the word under cursor

nnoremap <silent> <leader>t :tabe<CR>|		" Open a new tab
nnoremap <silent> <leader>z :tabc<CR>|		" Completely close the tab
nnoremap <silent> <leader>\ :make<CR>|		" make(1)
nnoremap <silent> <leader>q :only<CR>|		" Close all other windows
nnoremap <silent> <leader>w :set nowrap!<CR>|	" Toggle visual line wrapping
nnoremap <leader>n :norm|
nnoremap <silent> <C-n> :cn<CR>|		" Open next quickfix item
nnoremap <silent> <C-f> :cp<CR>|		" Open previous quickfix item
nnoremap <silent> <C-e> :cfirst<CR>|		" Open first quickfix item
nnoremap <silent> <C-a> :clast<CR>|		" Open last quickfix item
nnoremap <silent> <C-k> :tabnew %<CR>|		" Open current window in tab

" TS LSP
" Go to definition
nmap gd <plug>(lsp-definition)
" Find references
nmap gr <plug>(lsp-references)
" Hover documentation
nmap K <plug>(lsp-hover)
" Rename symbol
nmap <F2> <plug>(lsp-rename)
" Next/previous diagnostic
nmap ]d <plug>(lsp-next-diagnostic)
nmap [d <plug>(lsp-previous-diagnostic)
nnoremap <C-i> <plug>(lsp-code-action)
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_document_highlight_enabled = 0

" Invoke the file of the current buffer and open its output in new split.
func! ExecFile()
	let f = expand('%:p')
	let out = systemlist(f)
	if empty(out)
		return
	endif
	belowright 15new
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
	call setline(1, out)
endfunc
com! ExecFile call ExecFile()
noremap <leader>e :ExecFile<CR>
aug ShSpecial
	au!
	" Check shell script syntax (current buffer)
	au! filetype sh setlocal errorformat=%f:\ %l:\ %m
	au! filetype sh setlocal makeprg=sh\ -n\ %
aug END


" prabirshrestha/vim-lsp
"
if executable('typescript-language-server')
	aug LspTypeScript
		au!
		au User lsp_setup call lsp#register_server({
					\ 'name': 'typescript-language-server',
					\ 'cmd': {server_info->[
					\     'typescript-language-server',
					\     '--stdio'
					\ ]},
					\ 'allowlist': ['typescript', 'typescriptreact', 'javascript', 'javascriptreact'],
					\ })
	aug END
endif

" tpope/vim-fugitive
"
func! GitLogLine()
	let start = line("'<")
	let end = line("'>")
	execute "Git log -L" . start . "," . end . ":" . expand("%")
endfunc

nnoremap <leader>l :Git log -- %<CR>
xnoremap <leader>l :<C-U>call GitLogLine()<CR>
nnoremap <leader>d :Git diff %<CR>
nnoremap <leader>1 :Git branch
nnoremap <leader>s :Git<CR>
nnoremap <leader>b :Git branch<CR>

aug FugitiveMappings
	au!
	au filetype fugitive nnoremap <buffer> 00 :Git pop -q<CR>
aug END

iabbrev ddd fprintf(stderr, "%s():%d\n", __func__, __LINE__)
aug quickfix
	au!
	" Automatic location/quickfix window
	" See comments regarding 'redraw!' in Grep command definition above.
	au QuickFixCmdPost [^l]* 15cwindow |redraw!
	au QuickFixCmdPost    l* lwindow
aug END
