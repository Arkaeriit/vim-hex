
" This group ensure that when a file is oppened as binary, it is hexdump on
" reading and binarized on writting
augroup VimHex
  au!
  au BufReadPost,FileReadPost,BufNewFile * if &bin | call vim_hex#OpenHex() | endif
  au BufWritePost,FileWritePost * if &bin | call vim_hex#SaveHex() | endif
augroup END

