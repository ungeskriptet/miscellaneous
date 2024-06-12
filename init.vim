set ignorecase
set laststatus=0 ruler
set incsearch
set guicursor=n-v-c-i:block
set autoindent noexpandtab tabstop=8 shiftwidth=8
set mouse=
syntax on
highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$/
map q <nop>
