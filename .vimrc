set nocompatible

call plug#begin('~/.vim/plugged')
Plug 'ervandew/supertab'
Plug 'fatih/vim-go'
Plug 'Rip-Rip/clang_complete'
Plug 'vimwiki/vimwiki'
call plug#end()

set listchars=tab:>-,trail:~,extends:>,precedes:<
set list

filetype plugin indent on
autocmd FileType make set modelines=0 " to enable targets like `vim' in makefile
set whichwrap=b,s,<,>,[,] "move cursor, to next line automatically

set wrap
set linebreak

"set expandtab "do not expand with spaces
set tabstop=8
set softtabstop=8
set shiftwidth=8

let c_space_errors = 1 "highligth bad spaces in c code

" for works on russian keymap (keybinding)
set keymap=russian-jcukenwin
set iminsert=0
set imsearch=0
highlight lCursor guifg=NONE guibg=Cyan

syntax enable
set t_Co=256 "color count

" assume that `*.t' is a perl files
au BufRead,BufNewFile *.t set filetype=perl

set relativenumber
set showmatch
syntax on

" don't override register after paste
xnoremap p pgvy

colorscheme ron
if &diff
	colorscheme industry
endif

" all for search
set ignorecase
set smartcase
set incsearch
set hlsearch

set history=50	" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands

set autoindent 	" auto spacing
set smartindent " smart spacing
set cindent "aotumatic c programms indenting

" session options
set sessionoptions=curdir,buffers,tabpages

"autocmd FileType python set omnifunc=pythoncomplete#Complete
set complete+=. "from current buffer
set complete+=k "from dictionary
set complete+=b "from other buffers
set complete+=t "from tags

" encoding
set termencoding=utf-8
set fileencodings=utf8,cp1251,koi8
set encoding=utf8

set bs=2 "for diffrent backspace
set completeopt=menuone,menu,longest ",preview
set tags=tags
"set tags=/path1, /paht*... etc to tag files

set statusline=%F%m%r%h%w\ [%04l,%04v][%p%%] " формат строки состояния
"hi statusline gui=reverse cterm=reverse " делать ее черной, а не белой
set laststatus=2 " всегда показывать строку состояния

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                    nerdcommenter plugin options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let NERDComInsertMap='<c-c>' "ctrl + c in insert mode add a comment 
let NERDCommentWholeLinesInVMode = 2 "comment whole line, if no multipart comments 
let NERDMenuMode = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                       supertab options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType *
    \ if &omnifunc != ''                                    |
    \   call SuperTabSetDefaultCompletionType("<c-x><c-u>") |
    \ else                                                  |
    \   call SuperTabSetDefaultCompletionType("context")    |
    \ endif

autocmd FileType go call SuperTabSetDefaultCompletionType("<c-x><c-o>")

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                      clang_complete options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:clang_auto_select = 1
let g:clang_complete_auto = 1
let g:clang_hl_errors = 1

let g:clang_snippets = 1
let g:clang_snippets_engine = 'clang_complete'
let g:clang_user_options='-std=c++0x'

let g:clang_close_preview = 1

let g:clang_use_library = 1
let g:clang_library_path = '/usr/lib/llvm-10/lib/'

let g:clang_complete_macros = 1
let g:clang_complete_patterns = 1

"let g:clang_user_options = '-std=c++11'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                      vim-go options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:go_info_mode = 'gopls'
let g:go_def_mode = 'gopls'
let g:go_autodetect_gopath = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                      vimwiki options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:vimwiki_list = [{'path': '~/self/wikis/', 'syntax': 'markdown', 'ext': '.md', 'index': 'README'}, {'path': '~/work/', 'syntax': 'markdown', 'ext': '.md', 'index': 'index'}]
let g:vimwiki_global_ext = 0
let g:vimwiki_auto_chdir = 1
