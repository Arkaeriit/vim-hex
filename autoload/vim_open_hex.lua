package.path = vim.eval("g:vim_hex_dir") .. "/?.lua"
local vim_hex = require("vim_hex")

local copy = vim_hex.get_buff()
vim.command("let b:vim_hex_buffer_copy = '" .. vim_hex.hex_edit.reduced_hd(copy):gsub(" ", "") .. "'") -- Put in the vim variable an hexdump of the last valid version of the file.
vim_hex.hd_vim_buffer()

