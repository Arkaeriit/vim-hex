package.path = vim.eval("g:vim_hex_dir") .. "/?.lua"
package.cpath = vim.eval("g:vim_hex_dir") .. "/?.so"
local vim_hex = require("vim_hex")

vim_hex.hd_vim_buffer()

