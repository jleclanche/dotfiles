syntax on

" UI options
set cursorline " Highlight the current line
set number " Enable line numbers
set relativenumber " Hybrid relative line numbers
set showmatch " Show matching brackets
set wildmode=list:longest
set ff=unix " Display DOS line endings

" Indentation options
set list listchars=tab:»\ ,trail:·
set noexpandtab
set copyindent
set preserveindent
set softtabstop=0
set shiftwidth=4
set tabstop=4

" Clipboard options
set clipboard+=unnamedplus " Yanks go on clipboard instead
"set paste pastetoggle=<F10>
set viminfo='50,<1000,s100,h " Set max buffer size to 1000 lines (default 50)

" Search options
set ignorecase
set smartcase
" Use <C-L> to clear the highlighting of hlsearch
nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

" Scrolloff options
set scrolloff=1
set sidescrolloff=5

set lazyredraw

" Remove trailing spaces on save
autocmd BufWritePre * :%s/\s\+$//e

" Alias "write as sudo" as :w!!
cmap w!! w !sudo tee > /dev/null %

" Plugins
call plug#begin("~/.config/nvim/plugged")
	Plug 'jiangmiao/auto-pairs'
	Plug 'scrooloose/syntastic'
	Plug 'bling/vim-airline'
	Plug 'tpope/vim-fugitive'
	Plug 'fatih/vim-go', {'for': 'go'}
	Plug 'peterhoeg/vim-qml'
	Plug 'chriskempson/vim-tomorrow-theme'
call plug#end()

" Silent in case it's not set up yet
silent! colorscheme Tomorrow-Night-Bright

let g:airline_powerline_fonts = 1
let g:vim_markdown_folding_disabled=1 " Disable markdown folding
let g:syntastic_python_flake8_args = "--ignore=W191,E702 --max-line-length=92"
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
if exists('g:loaded_fugitive')
	set statusline+=%{fugitive#statusline()}
endif
