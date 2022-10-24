package.path = vim.eval("g:vim_hex_dir") .. "/?.lua"
local vim_hex = require("vim_hex")

local ok = vim_hex.binarize_vim_buffer()

if ok then -- save result and put it in the tmp buffer
    vim.command("silent w")
    local copy = vim_hex.get_buff()
    vim.command("let b:vim_hex_buffer_copy = '" .. vim_hex.hex_edit.reduced_hd(copy):gsub(" ", "") .. "'")
    vim_hex.hd_vim_buffer()
    vim.command("let b:vim_hex_error = 0") -- Ensure that we can leave without a warning
else -- read back from the tmp buffer to write but keep current buffer
    local current_buff = vim_hex.get_buff() 
    vim_hex.set_buff(vim_hex.hex_edit.binarize_hd(vim.eval("b:vim_hex_buffer_copy")))
    vim.command("silent w")
    vim_hex.set_buff(current_buff)
    vim.command("let b:vim_hex_error = 1") -- The file is marked as modified. Thus, it cannot be exited without a warning.
end

