set ignorecase
set nu
set laststatus=0 ruler
set incsearch
set guicursor=n-v-c-i:block
syntax on
highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$/
map q <nop>
