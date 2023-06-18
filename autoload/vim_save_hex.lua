package.path = vim.eval("g:vim_hex_dir") .. "/?.lua"
local vim_hex = require("vim_hex")

local ok = vim_hex.binarize_vim_buffer()

if ok then -- save result and put it in the tmp buffer
    vim.command('call vim_hex#safekeeping("raw")')
    vim.command("silent w")
    vim_hex.hd_vim_buffer()
    vim.command("let b:vim_hex_error = 0") -- Ensure that we can leave without a warning
else -- read back from the tmp buffer to write but keep current buffer
    vim.command('call vim_hex#safekeeping("formatted")')
    vim.command('call vim_hex#restore("raw")')
    vim.command("silent w")
    vim.command('call vim_hex#restore("formatted")')
    vim.command("let b:vim_hex_error = 1") -- The file is marked as modified. Thus, it cannot be exited without a warning.
end

