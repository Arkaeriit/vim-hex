package.path = vim.eval("g:vim_hex_dir") .. "/?.lua"
local vim_hex = require("vim_hex")

vim_hex.binarize_vim_buffer()
vim.command("w")
vim_hex.hd_vim_buffer()

