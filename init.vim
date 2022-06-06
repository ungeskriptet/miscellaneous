set ignorecase
set nu
set laststatus=0 ruler
set incsearch
syntax on
highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$/
map q <nop>
