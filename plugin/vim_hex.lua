local module = {}

local hex_eddit = require("hex_eddit")

-- Sets the current buffer to the string s
local function set_buf(s)
    local current_buffer = vim.buffer(false)
    for i=0,#current_buffer do
        current_buffer[1] = nil
    end
    local lines = hex_eddit.split_line(s)
    for i=1,#lines do
        current_buffer:insert("")
        current_buffer[i] = lines[i]
    end
end

-- Get the current buffer as a string
local function get_buf()
    local current_buffer = vim.buffer(false)
    local ret = ""
    for i=1,#current_buffer do
        ret = ret .. current_buffer[i] .. "\n"
    end
    return ret:sub(1,#ret-1)
end


-- Transform the current buffer into an hexdump of itself
module.hd_vim_buffer = function()
    bin_buff = get_buf()
    dumped_buff = hex_eddit.hd_buffer(bin_buff)
    set_buf(dumped_buff)
end

return module

