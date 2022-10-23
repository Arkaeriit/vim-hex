
augroup Binary
  au!
  au BufReadPost * if &bin | call vim_hex#OpenHex()
  au BufReadPost * endif
  au BufWritePost * if &bin | call vim_hex#SaveHex()
  au BufWritePost * endif
augroup END

