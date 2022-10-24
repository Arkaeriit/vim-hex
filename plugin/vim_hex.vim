
" This group ensure that when a file is opened as binary, it is hexdump on
" reading and binarized on writing
augroup VimHex
  au!
  au BufReadPost,FileReadPost,BufNewFile * if &bin | call vim_hex#OpenHex() | endif
augroup END
" I don't want this to be autoloaded as the &bin setting might be changed in
" the vimrc. In that case, I would have now way to know what to do here.

