local hex_edit = require("hex_edit")
local module = {hex_edit = hex_edit}
local new_hex_streamer = require("hex_stream")
local new_bin_streamer = require("bin_stream")

-- Sets the current buffer to the string s
local set_buff = function(s)
    local current_buffer = vim.buffer(false)
    for i=0,#current_buffer do
        current_buffer[1] = nil
    end
    local lines = hex_edit.split_line(s)
    for i=1,#lines do
        current_buffer:insert("")
        current_buffer[i] = lines[i]
    end
    current_buffer[#lines+1] = nil
end

-- Get the current buffer as a string
local get_buff = function()
    local current_buffer = vim.buffer(false)
    local ret = ""
    for i=1,#current_buffer do
        ret = ret .. current_buffer[i] .. "\n"
    end
    if (vim.eval("b:vim_hex_trailing")) == 1 then
        vim.command("let b:vim_hex_trailing = 0")
        return ret
    else
        return ret:sub(1,#ret-1)
    end
end


-- Transform the current buffer into an hexdump of itself
module.hd_vim_buffer = function()
    local current_buffer = vim.buffer(false)
    local processes_packets = {}
    local streamer = new_hex_streamer(tonumber(vim.eval("getfsize(expand(@%))")))
    
    for i=1,#current_buffer do
        processes_packets[#processes_packets+1] = streamer:process(current_buffer[1])
        if #current_buffer > 1 or (vim.eval("b:vim_hex_trailing")) == 1 then
            processes_packets[#processes_packets+1] = streamer:process("\n")
        end
        current_buffer[1] = nil
    end

    for i=1,#processes_packets do
        local lines = processes_packets[i]
        for j=1,#lines do
            current_buffer:insert("")
            current_buffer[#current_buffer] = lines[j]
        end
    end

    local lines = streamer:finish()
    for i=1,#lines do
        current_buffer:insert("")
        current_buffer[#current_buffer] = lines[i]
    end

    current_buffer[1] = nil
end

-- Transform the current hexdump buffer ack into binary
-- Return true if it can be done and false otherwise.
module.binarize_vim_buffer = function()
    local current_buffer = vim.buffer(false)
    local streamer = new_bin_streamer()
    local ok = true
    vim.command('call vim_hex#safekeeping("binarize")')


    for i=1,#current_buffer do
        local err = streamer:stream_line(current_buffer[1])
        if err then
            print(string.format("Error line %i:", i))
            print(err)
            ok = false
        end
        current_buffer[1] = nil
    end
    streamer:finish()

    vim.command("let b:vim_hex_trailing = 0") -- hack needed as the lines are well handled here
    if ok then
        for i=1,#streamer.lines do
            current_buffer:insert("")
            current_buffer[#current_buffer] = streamer.lines[i]
        end
        current_buffer[1] = nil
    else
        vim.command('call vim_hex#restore("binarize")')
    end
    return ok
end

return module

