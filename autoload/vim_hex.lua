local module = {}

local hex_eddit = require("hex_eddit")

-- Sets the current buffer to the string s
module.set_buff = function(s)
    local current_buffer = vim.buffer(false)
    for i=0,#current_buffer do
        current_buffer[1] = nil
    end
    local lines = hex_eddit.split_line(s)
    for i=1,#lines do
        current_buffer:insert("")
        current_buffer[i] = lines[i]
    end
    current_buffer[#lines+1] = nil
end

-- Get the current buffer as a string
module.get_buff = function()
    local current_buffer = vim.buffer(false)
    local ret = ""
    for i=1,#current_buffer do
        ret = ret .. current_buffer[i] .. "\n"
    end
    return ret:sub(1,#ret-1)
end


-- Transform the current buffer into an hexdump of itself
module.hd_vim_buffer = function()
    local bin_buff = module.get_buff()
    local dumped_buff = hex_eddit.hd_buffer(bin_buff)
    module.set_buff(dumped_buff)
end

-- Transform the current hexdump buffer ack into binary
-- Return true if it can be done and false otherwise.
module.binarize_vim_buffer = function()
    local dumped_buff = module.get_buff()
    local bin_buff, ok = hex_eddit.binarize_buffer(dumped_buff)
    if ok then
        module.set_buff(bin_buff)
    end
    return ok
end

return module

