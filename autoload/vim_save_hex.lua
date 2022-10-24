package.path = vim.eval("g:vim_hex_dir") .. "/?.lua"
local vim_hex = require("vim_hex")

local ok = vim_hex.binarize_vim_buffer()

if ok then -- save result and put it in the tmp buffer
    vim.command("w")
    vim.command("call vim_hex#BufferToVar()")
    vim_hex.hd_vim_buffer()
else -- read back from the tmp buffer to write but keep current buffer
    local current_buff = vim_hex.get_buff() 
    vim_hex.set_buff(vim.eval("b:vim_hex_buffer_copy"))
    vim.command("w")
    vim_hex.set_buff(current_buff)
end

