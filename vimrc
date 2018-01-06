" This option breaks some vi compatibility.
" This must be first, because it changes other options as a side effect.
set nocompatible

runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

syntax on
filetype plugin indent on

if !exists("g:os")
  if has("win64") || has("win32") || has("win16")
    let g:os = "Windows"
  else
    let g:os = substitute(system('uname'), '\n', '', '')
  endif
endif

"-----------------------------------------------------------------------------
" Settings
"-----------------------------------------------------------------------------
set expandtab
set shiftwidth=2
set softtabstop=2
set smarttab                    " Add and delete spaces in increments of `shiftwidth' for tabs

set backspace=indent,eol,start  " Makes backspace key more powerful.
set nocursorcolumn
set nocursorline
set noerrorbells                " No beeps for error messages.
set list                        " Display unprintable characters
set number                      " Show line numbers
set ruler                       " Show the line and column number of the cursor position
set showcmd                     " Show (partial) command in the last line of the screen
set noshowmatch                 " Do not show matching brackets by flickering
set showmode                    " Show current mode
"set noshowmode                  " We show the mode with airline or lightline

set history=50                  " Lines of command line history
set nobackup                    " No backup mode
set nowritebackup               " No backup mode
set swapfile
set undofile                    " Enable persistent undo
set undoreload=20000

set splitright                  " Split vertical windows right to the current windows
set splitbelow                  " Split horizontal windows below to the current windows
set encoding=utf-8              " Set default encoding to UTF-8
set autowrite                   " Automatically save before :next, :make etc.
set autoread                    " Automatically reread changed files without asking me anything
set laststatus=2
set hidden

"au FocusLost * :wa              " Set vim to save the file on focus out.

"set fileformats=unix,dos,mac    " Prefer Unix over Windows over OS 9 formats
set fileformat=unix
set fileformats=                " Don't detect line endings

set autoindent                  " Always set auto-indenting on
set showbreak=\\\\\\\
if exists("&breakindent")
  set breakindent
endif

set incsearch                   " Shows the match while typing
set hlsearch                    " Highlight found searches
"set ignorecase                  " Search case insensitive...
"set smartcase                   " ... but not when search pattern contains upper case characters

set lazyredraw                  " Wait to redraw
set ttyfast

set background=dark
if &t_Co > 2 || has("gui_running")
  colorscheme desert
endif

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
\ if line("'\"") > 1 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif

" Highlight trailing whitespace.
highlight WhitespaceEOL ctermbg=DarkYellow guibg=DarkYellow
if v:version >= 702
  " Whitespace at the end of a line. This little dance suppresses
  " whitespace that has just been typed.
  au BufWinEnter,WinEnter * let w:m1=matchadd('WhitespaceEOL', '\s\+$', -1)
  au InsertEnter * call matchdelete(w:m1)
  au InsertEnter * let w:m2=matchadd('WhitespaceEOL', '\s\+\%#\@<!$', -1)
  au InsertLeave * call matchdelete(w:m2)
  au InsertLeave * let w:m1=matchadd('WhitespaceEOL', '\s\+$', -1)
else
  au InsertEnter * syntax match WhitespaceEOL /\s\+\%#\@<!$/
  au InsertLeave * syntax match WhitespaceEOL /\s\+$/
endif

" LLVM Makefiles can have names such as Makefile.rules or TEST.nightly.Makefile,
" so it's important to categorize them as such.
augroup filetype
  au! BufRead,BufNewFile *Makefile* set filetype=make
augroup END

" In Makefiles, don't expand tabs to spaces, since we need the actual tabs
autocmd FileType make set noexpandtab

" Useful macros for cleaning up code to conform to LLVM coding guidelines

" Delete trailing whitespace and tabs at the end of each line
command! DeleteTrailingWs :%s/\s\+$//

" Convert all tab characters to two spaces
command! Untab :%s/\t/  /g

augroup filetype
  au! BufNewFile,BufRead *.vsh,*.fsh, set filetype=glsl
augroup END

" Enable syntax highlighting for LLVM files.
augroup filetype
  au! BufNewFile,BufRead *.ll set filetype=llvm
augroup END

" Enable syntax highlighting for LLVM tablegen files.
augroup filetype
  au! BufNewFile,BufRead *.td set filetype=tablegen
augroup END

" Enable syntax highlighting for protobuf files.
augroup filetype
  au! BufNewFile,BufRead *.proto set filetype=proto
augroup END

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
    \ | wincmd p | diffthis
endif

let g:rustfmt_command = "rustup run nightly rustfmt"
function! FormatRange() range
  let l:range = a:firstline . "," . a:lastline
  if &filetype == "python"
    execute l:range . 'call yapf#YAPF()'
  elseif &filetype == "rust"
    " FIXME(kal): Work around broken :RustFmtRange.
    " execute l:range . 'RustFmtRange'
    execute 'RustFmt'
  else
    if has("python3")
      execute l:range . 'py3file ~/.vim/bin/clang-format.py'
    elseif has("python")
      execute l:range . 'pyfile ~/.vim/bin/clang-format.py'
    endif
  endif
endfunction

"-----------------------------------------------------------------------------
" Key mappings
"-----------------------------------------------------------------------------
let mapleader = ","

" Sort function to a key
vnoremap <Leader>s :sort<CR>

" This changes the . command to leave the cursor at the point where it was
" before editing started.
nmap . :norm! .`[<CR>

" Stay in visual mode after shift.
vnoremap < <gv
vnoremap > >gv

" Keep search matches in the middle of the window.
nmap n :norm! nzzzv<CR>
nmap N :norm! Nzzzv<CR>

nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

map <C-h> :tabprevious<CR>
map <C-l> :tabnext<CR>
imap <C-h> <ESC>:tabprevious<CR>
imap <C-l> <ESC>:tabnext<CR>

map <C-J> :call FormatRange()<cr>
imap <C-J> <c-o>:call FormatRange()<cr>

if g:os == "Darwin"
  nmap <C-c> yy:call system("pbcopy", getreg("\""))<CR>
  nmap <C-x> dd:call system("pbcopy", getreg("\""))<CR>
  vmap <C-c> y:call system("pbcopy", getreg("\""))<CR>
  vmap <C-x> d:call system("pbcopy", getreg("\""))<CR>
endif

runtime local.vim
